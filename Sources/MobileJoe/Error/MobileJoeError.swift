//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  MobileJoeError.swift
//
//  Created by Florian Mielke on 20.03.25.
//

import Foundation

enum MobileJoeError: Error {
  case notConfigured
  case unknownIdentity
  case unknownFeatureRequest
  case invalidURL(components: URLComponents)
  case invalidHTTPResponse
  case notOkURLResponse(description: String)
  case generic(String)
}
