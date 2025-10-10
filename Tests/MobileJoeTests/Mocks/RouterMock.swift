//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  RouterMock.swift
//
//  Created by Florian on 10.10.25.
//

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
    
    if resultsQueue.isNotEmpty {
      return resultsQueue.removeFirst()
    }
    
    if let nextResult {
      return nextResult
    }
    
    throw Error.missingResult
  }
}
