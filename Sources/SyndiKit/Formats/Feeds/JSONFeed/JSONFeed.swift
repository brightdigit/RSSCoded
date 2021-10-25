import Foundation

public struct JSONFeed {
  public let version: URL
  public let title: String
  public let homePageUrl: URL
  public let description: String?

  /// The author of the feed.
  public let author: Author?
  public let items: [JSONItem]
}

extension JSONFeed: DecodableFeed {
  public var youtubeChannelID: String? {
    nil
  }

  public var children: [Entryable] {
    items
  }

  public var summary: String? {
    description
  }

  public var siteURL: URL? {
    homePageUrl
  }

  public var updated: Date? {
    nil
  }

  public var copyright: String? {
    nil
  }

  public var image: URL? {
    nil
  }

  public var syndication: SyndicationUpdate? {
    nil
  }

  public var authors: [Author] {
    guard let author = author else {
      return []
    }
    return [author]
  }

  static let source: DecoderSetup = DecoderSource.json
}
