//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  Router.swift
//
//  Created by Florian Mielke on 09.06.25.
//

import Foundation

@MainActor
protocol Router {
  func perform(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse)
}

class DefaultRouter: Router {
  func perform(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
    let response = try await URLSession.shared.data(for: request)
    guard response.1.isOK else { throw MobileJoeError.notOkURLResponse(description: response.1.description) }
    guard let httpResponse = response as? (Data, HTTPURLResponse) else { throw MobileJoeError.invalidHTTPResponse }
    return httpResponse
  }
}
