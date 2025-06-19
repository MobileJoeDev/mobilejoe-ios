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
  func perform(_ request: URLRequest) async throws -> (Data, URLResponse)
}


class DefaultRouter: Router {
  func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
    let response = try await URLSession.shared.data(for: request)
    guard response.1.isOK else {
      throw MobileJoeError.generic("Invalid response: \(response.1)")
    }
    return response
  }
}
