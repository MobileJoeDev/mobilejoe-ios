// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
@testable import MobileJoe

class RouterMock: Router {
  enum Error: Swift.Error {
    case missingResult
  }
  
  var lastRequest: URLRequest?
  var requests = [URLRequest]()
  var performCallCount = 0
  var resultsQueue = [(data: Data, response: HTTPURLResponse)]()
  var nextResult: (data: Data, response: HTTPURLResponse)?
  var nextError: Swift.Error?
  
  func perform(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
    performCallCount += 1
    lastRequest = request
    requests.append(request)

    if let error = nextError {
      nextError = nil
      throw error
    }

    let result: (data: Data, response: HTTPURLResponse)
    if resultsQueue.isNotEmpty {
      result = resultsQueue.removeFirst()
    } else if let nextResult {
      result = nextResult
    } else {
      throw Error.missingResult
    }

    try result.response.validate(for: request)
    return result
  }
}
