import Foundation

extension DecodingError {
  struct Dictionary: Error {
    internal init?(errors: [String: DecodingError]) {
      guard errors.count > 1 else {
        return nil
      }
      self.errors = errors
    }

    let errors: [String: DecodingError]
  }

  static func failedAttempts(_ errors: [String: DecodingError]) -> Self {
    let context = DecodingError.Context(
      codingPath: [],
      debugDescription: "Failed to decode data with several decoders.",
      underlyingError: Dictionary(errors: errors) ?? errors.first?.value
    )
    return DecodingError.dataCorrupted(context)
  }
}
