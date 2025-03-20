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
    shared.apiKey = apiKey
    shared.appUserID = appUserID.escaped
    return shared
  }

  public var featureRequests: [FeatureRequest] = []

  private var apiKey: String = "" {
    didSet {
      NetworkClient.configure(withAPIKey: apiKey)
    }
  }
  private var appUserID: String = ""
  private var featureRequestContainer = Set<FeatureRequest>()
  private let logger = Logger(subsystem: "MobileJoe", category: "MobileJoe")

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
    request.httpBody = try JSONEncoder().encode(["user_id": appUserID])
    let response = try await URLSession.shared.data(for: request)
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
