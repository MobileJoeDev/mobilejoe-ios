// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

/// A unique identifier for system entities that can be safely stored and transmitted.
///
/// Identifiers can be generated in two ways:
/// - As anonymous identifiers based on UUID
/// - From existing strings using secure hashing
///
/// All identifiers are prefixed with a namespace to distinguish their type and source.
public struct Identity: Equatable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
  public var id: String { externalID ?? anonymousID }

  public var description: String { id }
  public var debugDescription: String { id }

  let anonymousID: String
  private(set) var externalID: String?
  private(set) var deviceID: String

  init(externalID: String?) {
    anonymousID = "$MBJAnonymousID:\(UUID().compactString)"
    deviceID = "$MBJDeviceID:\(UUID().compactString)"
    update(externalID: externalID)
  }

  mutating func update(externalID: String?) {
    self.externalID = Self.hashExternalID(from: externalID)
  }
}

extension Identity {
  static let anonymousIDPattern = #"\$MBJAnonymousID:([a-z0-9]{32})$"#
  static let externalIDPattern = #"\$MBJExternalID:([a-z0-9]{32})$"#
  static let deviceIDPattern = #"\$MBJDeviceID:([a-z0-9]{32})$"#

  static func hashExternalID(from id: String?) -> String? {
    guard let id else { return nil }
    return "$MBJExternalID:\(id.sha256Truncated(length: 32))"
  }
}
