@testable import RSSCoded
import XCTest
import XMLCoder

internal extension JSONFeed {
  var homePageURLHttp: URL? {
    var components = URLComponents(url: homePageUrl, resolvingAgainstBaseURL: false)
    components?.scheme = "http"
    return components?.url
  }
}

extension Sequence {
  func mapPairResult<Success>(_ transform: @escaping (Element) throws -> Success) -> [(Element, Result<Success, Error>)] {
    map { element in
      (element, Result { try transform(element) })
    }
  }

  func mapResult<Success>(_ transform: @escaping (Element) throws -> Success) -> [Result<Success, Error>] {
    map { element in
      Result { try transform(element) }
    }
  }

  func flatResultMapValue<SuccessKey, SuccessValue, NewSuccess>(_ transform: @escaping (SuccessValue) throws -> NewSuccess) -> [(SuccessKey, Result<NewSuccess, Error>)] where Element == (SuccessKey, Result<SuccessValue, Error>) {
    map {
      let value = $0.1.flatMap { value in
        Result { try transform(value) }
      }
      return ($0.0, value)
    }
  }

  func flatResultMap<Success, NewSuccess>(_ transform: @escaping (Success) throws -> NewSuccess) -> [Result<NewSuccess, Error>] where Element == Result<Success, Error> {
    map {
      $0.flatMap { success in
        Result {
          try transform(success)
        }
      }
    }
  }
}

protocol DecodingDecoder {
  func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}

extension JSONDecoder: DecodingDecoder {}

extension XMLDecoder: DecodingDecoder {}

struct Decoding<DecoderType: DecodingDecoder, DecodingType: Decodable> {
  let decoder: DecoderType

  init(for _: DecodingType.Type, using decoder: DecoderType) {
    self.decoder = decoder
  }

  func decode(data: Data) throws -> DecodingType {
    return try decoder.decode(DecodingType.self, from: data)
  }
}

struct DateDecoder {
  let formatters: [DateFormatter]

  static let RSS = DateDecoder(basedOnFormats:
    "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
    "yyyy-MM-dd'T'HH:mm:ssXXXXX",
    "E, d MMM yyyy HH:mm:ss zzz")

  internal init(formatters: [DateFormatter]) {
    self.formatters = formatters
  }

  static func isoPOSIX(withFormat dateFormat: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = dateFormat
    return formatter
  }

  init(basedOnFormats formats: String...) {
    formatters = formats.map(Self.isoPOSIX(withFormat:))
  }

  func decode(from decoder: Decoder) throws -> Date {
    for formatter in formatters {
      let container = try decoder.singleValueContainer()
      let dateStr = try container.decode(String.self)

      if let date = formatter.date(from: dateStr) {
        return date
      }
    }
    throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid Date"))
  }
}

final class RSSCodedTests: XCTestCase {
  func parseJSON(fromDirectoryURL sourceURL: URL? = nil) throws -> [String: Result<JSONFeed, Error>] {
    let sourceURL = sourceURL ?? Self.jsonDirectoryURL
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .custom(DateDecoder.RSS.decode(from:))

    let decoding = Decoding(for: JSONFeed.self, using: decoder)

    let pairs = try dataFromDirectoryURL(sourceURL).flatResultMapValue { try decoding.decode(data: $0) }

    return Dictionary(uniqueKeysWithValues: pairs)
  }

  fileprivate func dataFromDirectoryURL(_ sourceURL: URL) throws -> [(String, Result<Data, Error>)] {
    let urls = try FileManager.default.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: nil, options: [])

    return urls.mapPairResult {
      try Data(contentsOf: $0)
    }.map {
      ($0.0.deletingPathExtension().lastPathComponent, $0.1)
    }
  }

  func parseXML(fromDirectoryURL sourceURL: URL? = nil) throws -> [String: Result<Feed, Error>] {
    let sourceURL = sourceURL ?? Self.xmlDirectoryURL
    let datas: [(String, Result<Data, Error>)]
    datas = try dataFromDirectoryURL(sourceURL)

    let decoder = XMLDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .custom(DateDecoder.RSS.decode(from:))
    decoder.trimValueWhitespaces = false

    let rssDecoding = Decoding(for: RSS.self, using: decoder)
    let feedDecoding = Decoding(for: AtomFeed.self, using: decoder)
    let pairs = datas.flatResultMapValue { data throws -> Feed in
      do {
        return Feed.atom(try feedDecoding.decode(data: data))
      } catch {
        return Feed.rss(try rssDecoding.decode(data: data))
      }
    }

    return Dictionary(uniqueKeysWithValues: pairs)
  }

  func testJSONXMLEquality() {}

  static let xmlDirectoryURL = URL(string: #file)!.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Data").appendingPathComponent("XML")

  static let jsonDirectoryURL = URL(string: #file)!.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Data").appendingPathComponent("JSON")
  func testExample() throws {
    let itemCount = 20

    let xmlFeeds = try parseXML()
    let jsonFeeds = try parseJSON()

    for (name, xmlResult) in xmlFeeds {
      guard let jsonResult = jsonFeeds[name] else {
        continue
      }

      let json: JSONFeed
      let rss: Feed

      do {
        json = try jsonResult.get()
        rss = try xmlResult.get()
      } catch {
        XCTAssertNil(error)
        continue
      }

      XCTAssertEqual(json.title, rss.title.trimmingCharacters(in: .whitespacesAndNewlines))
      XCTAssertEqual(json.homePageUrl.remainingPath, rss.homePageUrl?.remainingPath.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
      if let description = rss.description {
        XCTAssertEqual(json.description ?? "", description.trimmingCharacters(in: .whitespacesAndNewlines), "Description does not match for \(name)")

      } else {
        XCTAssertEqual(json.description?.count ?? 0, 0)
      }

      let items = zip(json.items.sorted(by: {
        $0.title < $1.title
      }), rss.entries.sorted(by: {
        $0.title < $1.title
      }))
      var count = 0
      for (jsonItem, rssItem) in items {
        XCTAssertEqual(jsonItem.title, rssItem.title)
        if count < itemCount {
          XCTAssertEqual(jsonItem.contentHtml, rssItem.contentHtml, jsonItem.title)
          count += 1
        }
      }

      // XCTAssertEqual( json.author, json.author)
      // XCTAssertEqual( json.items, json.items)
    }
  }
}

extension URL {
  var remainingPath: String {
    let path = self.path

    return path == "/" ? "" : path
  }
}
