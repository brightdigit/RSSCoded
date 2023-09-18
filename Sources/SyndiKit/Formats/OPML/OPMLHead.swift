import Foundation

public extension OPML {
  struct Head: Codable, Equatable {
    public let title: String?
    public let dateCreated: String?
    public let dateModified: String?
    public let ownerName: String?
    public let ownerEmail: String?
    public let ownerId: String?
    public let docs: String?
    public let expansionStates: [Int]?
    public let vertScrollState: Int?
    public let windowTop: Int?
    public let windowLeft: Int?
    public let windowBottom: Int?
    public let windowRight: Int?

    enum CodingKeys: String, CodingKey {
      case title
      case dateCreated
      case dateModified
      case ownerName
      case ownerEmail
      case ownerId
      case docs
      case expansionStates = "expansionState"
      case vertScrollState
      case windowTop
      case windowLeft
      case windowBottom
      case windowRight
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.title = try container.decodeIfPresent(String.self, forKey: .title)
      self.dateCreated = try container.decodeIfPresent(String.self, forKey: .dateCreated)
      self.dateModified = try container.decodeIfPresent(String.self, forKey: .dateModified)
      self.ownerName = try container.decodeIfPresent(String.self, forKey: .ownerName)
      self.ownerEmail = try container.decodeIfPresent(String.self, forKey: .ownerEmail)
      self.ownerId = try container.decodeIfPresent(String.self, forKey: .ownerId)
      self.docs = try container.decodeIfPresent(String.self, forKey: .docs)
      self.vertScrollState = try container.decodeIfPresent(Int.self, forKey: .vertScrollState)
      self.windowTop = try container.decodeIfPresent(Int.self, forKey: .windowTop)
      self.windowLeft = try container.decodeIfPresent(Int.self, forKey: .windowLeft)
      self.windowBottom = try container.decodeIfPresent(Int.self, forKey: .windowBottom)
      self.windowRight = try container.decodeIfPresent(Int.self, forKey: .windowRight)

      self.expansionStates = try container
        .decodeIfPresent(String.self, forKey: .expansionStates)?
        .components(separatedBy: ", ")
        .compactMap { Int($0) }
    }
  }
}
