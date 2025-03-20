//
//  File.swift
//  MobileJoe
//
//  Created by Florian on 20.03.25.
//

import Foundation

@MainActor
class NetworkClient {
  static let shared = NetworkClient()

  @discardableResult
  static func configure(withAPIKey apiKey: String, appUserID: String) -> NetworkClient {
    shared.apiKey = apiKey
    return shared
  }

  private var apiKey: String = ""
  private var appUserID: String = ""

  private static let serverHostURL = URL(string: "https://api.mobilejoe.dev")!
  private static let apiVersion = "v1"

  func getFeatureRequests() async throws -> (Data, URLResponse) {
    var urlComponents = URLComponents()
    urlComponents.scheme = Self.serverHostURL.scheme
    urlComponents.host = Self.serverHostURL.host
    urlComponents.path = "/\(Self.apiVersion)/feature_requests"
    urlComponents.queryItems = [
      URLQueryItem(name: "user_id", value: appUserID.escaped)
    ]

    var request = URLRequest(url: urlComponents.url!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "GET"
    return try await URLSession.shared.data(for: request)
  }

  func postVoteFeatureRequests(featureRequestID: Int) async throws -> (Data, URLResponse) {
    var urlComponents = URLComponents()
    urlComponents.scheme = Self.serverHostURL.scheme
    urlComponents.host = Self.serverHostURL.host
    urlComponents.path = "/\(Self.apiVersion)/feature_requests/\(featureRequestID)/vote"
    var request = URLRequest(url: urlComponents.url!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.httpBody = try JSONEncoder().encode(["user_id": appUserID.escaped])
    request.httpMethod = "POST"
    return try await URLSession.shared.data(for: request)
  }
}
