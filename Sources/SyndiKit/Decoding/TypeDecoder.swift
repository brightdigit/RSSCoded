import Foundation
import XMLCoder

internal protocol TypeDecoder {
  func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: DecodableFeed
}

extension JSONDecoder: TypeDecoder {}

extension XMLDecoder: TypeDecoder {}
