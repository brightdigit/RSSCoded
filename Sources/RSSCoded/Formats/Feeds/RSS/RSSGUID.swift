import Foundation

public enum RSSGUID: Codable, Equatable {
  case url(URL)
  case uuid(UUID)
  case path([String], separatedBy: String)
  case string(String)

  public init(from string: String) {
    if let url = URL(strict: string) {
      self = .url(url)
    } else if let uuid = UUID(uuidString: string) {
      self = .uuid(uuid)
    } else {
      let components = string.components(separatedBy: ":")
      if components.count > 1 {
        self = .path(components, separatedBy: ":")
      } else {
        let components = string.components(separatedBy: "/")
        if components.count > 1 {
          self = .path(components, separatedBy: "/")
        } else {
          self = .string(string)
        }
      }
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    self.init(from: string)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    let string: String
    switch self {
    case let .url(url):
      string = url.absoluteString
    case let .uuid(uuid):
      string = uuid.uuidString.lowercased()
    case let .path(components, separatedBy: separator):
      string = components.joined(separator: separator)
    case let .string(value):
      string = value
    }
    try container.encode(string)
  }
}
