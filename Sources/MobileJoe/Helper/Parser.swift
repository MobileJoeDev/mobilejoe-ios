// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

class Parser {
  func parse<T: Decodable>(_ data: Data) throws -> T {
    try JSONDecoder.shared.decode(T.self, from: data)
  }
}
