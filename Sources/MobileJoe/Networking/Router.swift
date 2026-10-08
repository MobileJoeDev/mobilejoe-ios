// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

protocol Router {
  func perform(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse)
}

class DefaultRouter: Router {
  private let session: URLSession

  init(session: URLSession = .shared) {
    self.session = session
  }

  func perform(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
    let (data, urlResponse) = try await session.data(for: request)
    guard let httpResponse = urlResponse as? HTTPURLResponse else { throw MobileJoeError.invalidHTTPResponse }
    guard urlResponse.isSuccessful else {
      throw MobileJoeError.httpFailure(
        statusCode: httpResponse.statusCode,
        method: request.httpMethod ?? "GET",
        path: request.url?.path ?? ""
      )
    }
    return (data, httpResponse)
  }
}
