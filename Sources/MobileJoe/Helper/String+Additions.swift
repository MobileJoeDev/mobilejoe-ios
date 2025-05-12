//
//  Copyright Florian Mielke. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  String+Additions.swift
//
//  Created by Florian on 20.03.25.
//

import Foundation

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
