//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestParser.swift
//
//  Created by Florian Mielke on 08.05.25.
//

import Foundation

class FeatureRequestParser {
  func parse(_ data: Data) throws -> FeatureRequest {
    try JSONDecoder.shared.decode(FeatureRequest.self, from: data)
  }

  func parse(_ data: Data) throws -> [FeatureRequest] {
    try JSONDecoder.shared.decode([FeatureRequest].self, from: data)
  }
}
