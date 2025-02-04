import Foundation

extension PodcastPerson {
  /// A private enum representing known roles for a podcast person.
  private enum KnownRole: String {
    case guest
    case host
    case editor
    case writer
    case designer
    case composer
    case producer

    /// Initializes a ``KnownRole`` with a case-insensitive string.
    init?(caseInsensitive: String) {
      self.init(rawValue: caseInsensitive.lowercased())
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
    /// Initializes a ``KnownRole`` with a ``Role`` value.
    init?(role: Role) {
      switch role {
      case .guest:
        self = .guest

      case .host:
        self = .host

      case .editor:
        self = .editor

      case .writer:
        self = .writer

      case .designer:
        self = .designer

      case .composer:
        self = .composer

      case .producer:
        self = .producer

      case .unknown:
        return nil
      }
    }
  }

  // swiftlint:enable function_body_length cyclomatic_complexity

  /// An enum representing the role of a podcast person.
  public enum Role: Codable, Equatable, RawRepresentable {
    case guest
    case host
    case editor
    case writer
    case designer
    case composer
    case producer
    case unknown(String)

    /// The raw value of the role.
    public var rawValue: String {
      if let knownRole = KnownRole(role: self) {
        return knownRole.rawValue
      } else if case let .unknown(string) = self {
        return string
      } else {
        fatalError(
          // swiftlint:disable:next line_length
          "Role attribute of <podcast:person> with value: \(self) should either be a ``KnownRole``, or unknown!"
        )
      }
    }

    /// Initializes a ``Role`` with a raw value.
    public init?(rawValue: String) {
      self.init(caseInsensitive: rawValue)
    }

    /// Initializes a ``Role`` with a case-insensitive string.
    public init(caseInsensitive: String) {
      if let knownRole = KnownRole(caseInsensitive: caseInsensitive) {
        self = .init(knownRole: knownRole)
      } else {
        self = .unknown(caseInsensitive)
      }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private init(knownRole: KnownRole) {
      switch knownRole {
      case .guest:
        self = .guest

      case .host:
        self = .host

      case .editor:
        self = .editor

      case .writer:
        self = .writer

      case .designer:
        self = .designer

      case .composer:
        self = .composer

      case .producer:
        self = .producer
      }
    }
  }
}
