// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

public struct Alert: Identifiable, Hashable, Codable {
  public let id: Int
  public let title: String
  public let message: String?
  public let kind: Kind
  public let occurredAt: Date
  public let createdAt: Date
  public let updatedAt: Date

  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case message
    case kind
    case occurredAt = "occurred_at"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }

  public init(id: Int, title: String, message: String?, kind: Kind, occurredAt: Date, createdAt: Date, updatedAt: Date) {
    self.id = id
    self.title = title
    self.message = message
    self.kind = kind
    self.occurredAt = occurredAt
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: Alert, rhs: Alert) -> Bool {
    lhs.id == rhs.id
  }
}

extension Alert {
  public enum Kind: String, Codable {
    case warning
    case error
  }
}
