// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import CryptoKit

extension String {
  var cleaned: String {
    self
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
  }

  /// Returns a truncated SHA256 hash of the string as a hexadecimal string
  /// - Parameter length: The number of characters to include in the result
  /// - Returns: A hexadecimal string representation of the hash, truncated to the specified length
  func sha256Truncated(length: Int) -> String {
    let inputData = Data(self.utf8)
    let hashed = SHA256.hash(data: inputData)
    let hexString = hashed.compactMap { String(format: "%02x", $0) }.joined()
    return String(hexString.prefix(length))
  }
}
