// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

extension URLResponse {
  var isSuccessful: Bool {
    guard let statusCode = (self as? HTTPURLResponse)?.statusCode else { return false }
    return statusCode >= 200 && statusCode < 300
  }
}
