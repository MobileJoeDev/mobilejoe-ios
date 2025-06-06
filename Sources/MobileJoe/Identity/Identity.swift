//
//  File.swift
//  MobileJoe
//
//  Created by Florian on 09.05.25.
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

  var ids: [String] {
    var id = [anonymousID]
    if let externalID {
      id.append(externalID)
    }
    return id
  }

  private static let anonymousRegex = #"\$MBJAnonymousID:([a-z0-9]{32})$"#
}

extension Identity {
  private func generateExternalID(from id: String?) -> String? {
    guard let id else { return nil }
    return "$MBJExternalID:\(id.cleaned.sha256Truncated(length: 32))"
  }
}
