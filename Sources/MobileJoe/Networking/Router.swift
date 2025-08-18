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

protocol Router: Sendable {
  func perform(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse)
}

final class DefaultRouter: Router, @unchecked Sendable {
  func perform(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
    let (data, urlResponse) = try await URLSession.shared.data(for: request)
    guard urlResponse.isOK else { throw MobileJoeError.notOkURLResponse(description: urlResponse.description) }
    guard let httpResponse = urlResponse as? HTTPURLResponse else { throw MobileJoeError.invalidHTTPResponse }
    return (data, httpResponse)
  }
}
