//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  Identity.swift
//
//  Created by Florian Mielke on 09.05.25.
//

import Foundation
import CryptoKit

/// A unique identifier for system entities that can be safely stored and transmitted.
///
/// Identifiers can be generated in two ways:
/// - As anonymous identifiers based on UUID
/// - From existing strings using secure hashing
///
/// All identifiers are prefixed with a namespace to distinguish their type and source.
struct Identity: Equatable, Codable {
  let anonymousID: String
  private(set) var externalID: String?

  init(externalID: String?) {
    anonymousID = "$MBJAnonymousID:\(UUID().compactString)"
    update(externalID: externalID)
  }

  mutating func update(externalID: String?) {
    self.externalID = Self.generateExternalID(from: externalID)
  }

  var identifiersRepresentation: [String] {
    var ids = [anonymousID]
    if let externalID {
      ids.append(externalID)
    }
    return ids
  }
}

extension Identity {
  static let anonymousIDPattern = #"\$MBJAnonymousID:([a-z0-9]{32})$"#
  static let externalIDPattern = #"\$MBJExternalID:([a-z0-9]{32})$"#

  static func generateExternalID(from id: String?) -> String? {
    guard let id else { return nil }
    return "$MBJExternalID:\(id.sha256Truncated(length: 32))"
  }
}
