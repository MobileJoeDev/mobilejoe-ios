// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

public struct FAQItem: Identifiable, Hashable, Codable {
  public let id: Int
  public let title: String
  public let body: String
  public let position: Int
  public let createdAt: Date
  public let updatedAt: Date

  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case body
    case position
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }

  public init(id: Int, title: String, body: String, position: Int, createdAt: Date, updatedAt: Date) {
    self.id = id
    self.title = title
    self.body = body
    self.position = position
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: FAQItem, rhs: FAQItem) -> Bool {
    lhs.id == rhs.id
  }
}
