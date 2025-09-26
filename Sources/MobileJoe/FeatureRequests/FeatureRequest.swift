//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequest.swift
//
//  Created by Florian Mielke on 20.03.25.
//

import Foundation

public struct FeatureRequest: Identifiable, Hashable, Codable, Sendable {
  public let id: Int
  public let title: String
  public let body: String
  public let score: Int
  public let status: Status
  public let createdAt: Date
  public let updatedAt: Date
  public let isVoted: Bool

  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case body
    case score
    case status = "status_identifier"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case isVoted = "voted"
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: FeatureRequest, rhs: FeatureRequest) -> Bool {
    lhs.id == rhs.id
  }
}

extension FeatureRequest {
  public enum Sorting: String, CaseIterable, Identifiable {
    case byNewest = "created"
    case byScore = "score"

    public var id: Self { self }
  }
}

extension FeatureRequest {
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
