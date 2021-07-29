//
//  File.swift
//  File
//
//  Created by Leo Dion on 7/29/21.
//

import Foundation

extension KeyedDecodingContainerProtocol {
  func decodeDateIfPresentAndValid(forKey key: Key) throws -> Date? {
    if let pubDateString =
      try decodeIfPresent(String.self, forKey: key),
      !pubDateString.isEmpty {
      return DateFormatterDecoder.RSS.decoder.decodeString(pubDateString)
    }
    return nil
  }
}
