import Foundation
@testable import SyndiKit
import XMLCoder

enum Content {
  typealias ResultDictionary<SuccessValueType> = [String: Result<SuccessValueType, Error>]

  fileprivate static func resultDictionaryFrom<SuccessValueType>(
    directoryURL: URL,
    by closure: @escaping (Data) throws -> SuccessValueType
  ) throws -> ResultDictionary<SuccessValueType> {
    let xmlDataSet = Result {
      try FileManager.default.dataFromDirectory(at: directoryURL)
    }

    return try xmlDataSet.map { xmlDataSet in
      xmlDataSet.flatResultMapValue(closure)
    }.map(Dictionary.init(uniqueKeysWithValues:)).get()
  }

  static let synDecoder = SynDecoder()
  static let xmlDecoder = XMLDecoder()

  static let xmlFeeds = try! Content.resultDictionaryFrom(
    directoryURL: Directories.XML,
    by: Self.synDecoder.decode(_:)
  )
  static let jsonFeeds = try! Content.resultDictionaryFrom(
    directoryURL: Directories.JSON,
    by: Self.synDecoder.decode(_:)
  )
  static let opml = try! Content.resultDictionaryFrom(
    directoryURL: Directories.OPML,
    by: Self.xmlDecoder.decodeOPML(_:)
  )
  static let wordpressDataSet = try! FileManager.default.dataFromDirectory(
    at: Directories.WordPress
  )
  static let blogs: SiteCollection = try! .init(contentsOf: Directories.data.appendingPathComponent("blogs.json"))
  // swiftlint:enable force_try line_length
}

extension XMLDecoder {
  func decodeOPML(_ data: Data) throws -> OPML {
    try decode(OPML.self, from: data)
  }
}
