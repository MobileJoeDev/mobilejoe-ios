//
//  File.swift
//  MobileJoe
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
