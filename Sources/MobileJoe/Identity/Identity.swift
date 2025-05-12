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
  let externalID: String?

  /// Creates an anonymous identifier based on a UUID.
  ///
  /// The result is prefixed with "$MBJAnonymousID:" to indicate its type.
  ///
  /// - Returns: A new anonymous identifier
  private init(externalID: String) {
    self.externalID = "$MBJExternalID:\(externalID.cleaned.sha256Truncated(length: 32))"
  }

  static func generateAnonymousIDIfNeeded() -> String {
    "$MBJAnonymousID:\(UUID().compactString)"
  }

  private static let anonymousRegex = #"\$MBJAnonymousID:([a-z0-9]{32})$"#
}
