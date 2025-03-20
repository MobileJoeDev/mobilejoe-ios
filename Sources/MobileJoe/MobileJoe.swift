//
//  Copyright MobileJoe. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  Logger.swift
//
//  Created by Florian Mielke on 20/03/25.
//

import Foundation
import SwiftUI
import OSLog

@MainActor
@Observable
public class MobileJoe {
  public static let shared = MobileJoe()

  public var featureRequests: [FeatureRequest] = []

  private var featureRequestContainer = Set<FeatureRequest>()
  private let logger = Logger(subsystem: "MobileJoe", category: "MobileJoe")
  private let apiKey = "f5207a5941ab5449c6f7c61dbb5c9215"

  private init() {
  }

  public func fetchFeatureRequests() async throws {
    let url = URL(string: "https://api.mobilejoe.dev/v1/feature_requests")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    let result = try await URLSession.shared.data(for: request)
    try await handle(result)
  }

  public func vote(for featureRequest: FeatureRequest) async throws {
    let url = URL(string: "https://api.mobilejoe.dev/v1/feature_requests/\(featureRequest.id)/vote")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    let response = try await URLSession.shared.data(for: request)
    guard is200Response(response.1) else {
      throw MobileJoeError.generic("Invalid response: \(response.1)")
    }

    let result = try decoder.decode(FeatureRequest.self, from: response.0)
    featureRequestContainer.remove(result)
    featureRequestContainer.insert(result)
    featureRequestsDidUpdate()
  }

  public func sortByScore() {
    featureRequests.sort { lhs, rhs in
      if lhs.score == rhs.score {
        return lhs.id < rhs.id
      }
      return lhs.score > rhs.score
    }
  }

  public func sortByDate() {
    featureRequests.sort { lhs, rhs in
      if lhs.updatedAt == rhs.updatedAt {
        return lhs.id < rhs.id
      }
      return lhs.updatedAt > rhs.updatedAt
    }
  }

  private func handle(_ responseData: (Data, URLResponse)) async throws {
    let data = responseData.0
    let response = responseData.1

    guard is200Response(response) else {
      throw MobileJoeError.generic("Invalid response: \(response)")
    }

    let result = try decoder.decode([FeatureRequest].self, from: data)
    featureRequestContainer = Set(result)
    featureRequestsDidUpdate()
  }

  private func featureRequestsDidUpdate() {
    featureRequests = Array(featureRequestContainer).sorted { lhs, rhs in
      if lhs.score == rhs.score {
        return lhs.updatedAt > rhs.updatedAt
      }
      return lhs.score > rhs.score
    }
  }

  private func is200Response(_ response: URLResponse) -> Bool {
    (response as? HTTPURLResponse)?.statusCode == 200
  }

  @ObservationIgnored
  private lazy var decoder: JSONDecoder = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = .utc
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(formatter)
    return decoder
  }()
}

extension MobileJoe {
  public struct FeatureRequest: Identifiable, Hashable, Codable {
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
}
