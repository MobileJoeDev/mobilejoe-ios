// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

extension UUID {
  /// Returns a compact string representation of the UUID without hyphens and in lowercase
  var compactString: String {
    uuidString.replacingOccurrences(of: "-", with: "").lowercased()
  }
}
