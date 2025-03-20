//
//  Copyright Florian Mielke. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  MobileJoe.swift
//
//  Created by Florian on 20.03.25.
//

import Foundation
import OSLog

@MainActor
@Observable
public class MobileJoe {
  public static let shared = MobileJoe()

  @discardableResult
  public static func configure(withAPIKey apiKey: String, appUserID: String) -> MobileJoe {
    NetworkClient.configure(withAPIKey: apiKey, appUserID: appUserID)
    return shared
  }

  public var featureRequests: [FeatureRequest] = []

  private var featureRequestContainer = Set<FeatureRequest>()
  private let logger = Logger(subsystem: "MobileJoe", category: "MobileJoe")

  private init() {
  }

  public func fetchFeatureRequests() async throws {
    let response = try await NetworkClient.shared.getFeatureRequests()
    try await handle(response)
  }

  public func vote(for featureRequest: FeatureRequest) async throws {
    let response = try await NetworkClient.shared.postVoteFeatureRequests(featureRequestID: featureRequest.id)
    guard is200Response(response.1) else {
      throw MobileJoeError.generic("Invalid response: \(response.1)")
    }

    let result = try JSONDecoder.shared.decode(FeatureRequest.self, from: response.0)
    featureRequestContainer.remove(result)
    featureRequestContainer.insert(result)
    featureRequestsDidUpdate()
  }
}

extension MobileJoe {
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

    let result = try JSONDecoder.shared.decode([FeatureRequest].self, from: data)
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
}
