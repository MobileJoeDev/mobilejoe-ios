//
//  Copyright Florian Mielke. All Rights Reserved.
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
  public let status: String
  public let updatedAt: Date
  public let isVoted: Bool
  public let statusHexColor: String

  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case body
    case score
    case status
    case statusHexColor = "status_color"
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
