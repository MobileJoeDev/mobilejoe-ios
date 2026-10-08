// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

@Observable
public class FeaturePlan: Identifiable, Hashable, Codable {
  public let id: Int
  public let title: String
  public let body: String
  public private(set) var score: Int
  public let status: Status
  public let createdAt: Date
  public private(set) var updatedAt: Date
  public private(set) var isVoted: Bool

  init(id: Int, title: String, body: String, score: Int, status: Status, createdAt: Date, updatedAt: Date, isVoted: Bool) {
    self.id = id
    self.title = title
    self.body = body
    self.score = score
    self.status = status
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.isVoted = isVoted
  }

  func update(from featurePlan: FeaturePlan) {
    guard id == featurePlan.id else { return }
    score = featurePlan.score
    updatedAt = featurePlan.updatedAt
    isVoted = featurePlan.isVoted
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case body
    case score
    case status
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case isVoted = "voted"
  }

  required public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(Int.self, forKey: .id)
    self.title = try container.decode(String.self, forKey: .title)
    self.body = try container.decode(String.self, forKey: .body)
    self.score = try container.decode(Int.self, forKey: .score)
    self.status = try container.decode(Status.self, forKey: .status)
    self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    self.isVoted = try container.decode(Bool.self, forKey: .isVoted)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.title, forKey: .title)
    try container.encode(self.body, forKey: .body)
    try container.encode(self.score, forKey: .score)
    try container.encode(self.status, forKey: .status)
    try container.encode(self.createdAt, forKey: .createdAt)
    try container.encode(self.updatedAt, forKey: .updatedAt)
    try container.encode(self.isVoted, forKey: .isVoted)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: FeaturePlan, rhs: FeaturePlan) -> Bool {
    lhs.id == rhs.id
  }
}

extension FeaturePlan {
  public enum Sorting: String, CaseIterable, Identifiable {
    case byNewest = "created"
    case byScore = "score"

    public var id: Self { self }
  }

  public enum Status: String, Codable {
    case unknown = "unknown"
    case open = "open"
    case underReview = "under_review"
    case planned = "planned"
    case inProgress = "in_progress"
    case completed = "completed"
    case closed = "closed"
  }
}
