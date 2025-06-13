//
//  Copyright Florian Mielke. All Rights Reserved.
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
    self.anonymousID = "$MBJAnonymousID:\(UUID().compactString)"
    update(externalID: externalID)
  }

  mutating func update(externalID: String?) {
    self.externalID = generateExternalID(from: externalID)
  }

  var idStringRepresentation: String {
    ids.joined(separator: ",")
  }

  private var ids: [String] {
    var id = [anonymousID]
    if let externalID {
      id.append(externalID)
    }
    return id
  }
}

extension Identity {
  private func generateExternalID(from id: String?) -> String? {
    guard let id else { return nil }
    return "$MBJExternalID:\(id.sha256Truncated(length: 32))"
  }
}
