import Foundation

/// ```xml
/// <podcast:chapters 
///   url="https://example.com/episode1/chapters.json"
///   type="application/json+chapters"
/// />
/// ```
public struct PodcastChapters: Codable, Equatable {
  public let url: URL
  public let type: MimeType

  enum CodingKeys: String, CodingKey {
    case url
    case type
  }
}
