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
    var components = try url(for: "feature_requests")
    components.queryItems = [URLQueryItem(name: "user_id", value: appUserID.escaped)]
    guard let url = components.url else {
      throw MobileJoeError.generic("Invalid URL")
    }
    var request = urlRequest(for: url)
    request.httpMethod = "GET"
    return try await URLSession.shared.data(for: request)
  }
  
  func postVoteFeatureRequests(featureRequestID: Int) async throws -> (Data, URLResponse) {
    let components = try url(for: "feature_requests/\(featureRequestID)/vote")
    guard let url = components.url else {
      throw MobileJoeError.generic("Invalid URL")
    }
    var request = urlRequest(for: url)
    request.httpBody = try JSONEncoder().encode(["user_id": appUserID.escaped])
    request.httpMethod = "POST"
    return try await URLSession.shared.data(for: request)
  }
  
  private func urlRequest(for url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    return request
  }
  
  private func url(for path: String) throws -> URLComponents {
    var urlComponents = URLComponents()
    urlComponents.scheme = NetworkClient.serverHostURL.scheme
    urlComponents.host = NetworkClient.serverHostURL.host
    urlComponents.path = "/\(NetworkClient.apiVersion)/\(path)"
    return urlComponents
  }
}
