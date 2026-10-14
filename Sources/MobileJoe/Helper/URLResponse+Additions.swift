// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

extension URLResponse {
  var isSuccessful: Bool {
    guard let statusCode = (self as? HTTPURLResponse)?.statusCode else { return false }
    return statusCode >= 200 && statusCode < 300
  }
}

extension HTTPURLResponse {
  func validate(for request: URLRequest) throws {
    guard statusCode != 401 else { throw MobileJoeError.invalidAPIKey }
    guard isSuccessful else {
      throw MobileJoeError.httpFailure(statusCode: statusCode, method: request.httpMethod ?? "GET", path: request.url?.path ?? "")
    }
  }
}
