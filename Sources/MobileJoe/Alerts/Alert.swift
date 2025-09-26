//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  Alert.swift
//
//  Created by Florian Mielke on 25.09.25.
//

import Foundation

public struct Alert: Identifiable, Hashable, Codable {
  public let id: Int
  public let title: String?
  public let message: String
  public let kind: Kind
  public let dismissive: Dismissive
  public let createdAt: Date
  public let updatedAt: Date

  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case message
    case kind
    case dismissive
    case createdAt = "created_at"
    case updatedAt = "updated_at"
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
    case info
    case warning
    case error
  }
}

extension Alert {
  public enum Dismissive: String, Codable {
    case interactively
    case never
    case temporarily
  }
}
