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
  static func configure(withAPIKey apiKey: String, appUserID: String?) async throws -> NetworkClient {
    shared.apiKey = apiKey
    shared.identity = try await IdentityManager.shared.findOrCreate(with: appUserID)
    return shared
  }

  static func identify(appUserID: String) async throws {
    shared.identity = try await IdentityManager.shared.updateIfNeeded(shared.identity!, with: appUserID)
  }

  static var isConfigured: Bool {
    shared.apiKey.isNotEmpty
  }

  private static let serverHostURL = URL(string: "https://mbj-api.com")!
  private static let apiVersion = "v1"

  private var apiKey: String = ""
  private var identity: Identity?
}

// MARK: - FeatureRequests
extension NetworkClient {
  func getFeatureRequests() async throws -> Data {
    let request = try makeGetFeatureRequests()
    let response = try await perform(request)
    return response.0
  }

  func postVoteFeatureRequests(featureRequestID: Int) async throws -> Data {
    let request = try makePostVoteFeatureRequest(for: featureRequestID)
    let response = try await perform(request)
    return response.0
  }

  private func makeGetFeatureRequests() throws -> URLRequest {
    var components = try url(for: "feature_requests")
    guard let identifiersQueryParameter = identity?.idStringRepresentation else {
      throw MobileJoeError.generic("Could not generate identifiers")
    }
    components.queryItems = [URLQueryItem(name: "identifiers", value: identifiersQueryParameter)]
    guard let url = components.url else {
      throw MobileJoeError.generic("Invalid URL")
    }

    var request = urlRequest(for: url)
    request.httpMethod = "GET"
    return request
  }

  private func makePostVoteFeatureRequest(for featureRequestID: Int) throws -> URLRequest {
    let components = try url(for: "feature_requests/\(featureRequestID)/vote")
    guard let url = components.url else {
      throw MobileJoeError.generic("Invalid URL")
    }
    guard let identifiersParameter = identity?.idStringRepresentation else {
      throw MobileJoeError.generic("Could not generate identifiers")
    }
    var request = urlRequest(for: url)
    request.httpBody = try JSONEncoder().encode(["identifiers": identifiersParameter])
    request.httpMethod = "POST"
    return request
  }
}

// MARK: - Helper
extension NetworkClient {
  private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
    let response = try await URLSession.shared.data(for: request)
    guard response.1.isOK else {
      throw MobileJoeError.generic("Invalid response: \(response.1)")
    }
    return response
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

extension NetworkClient {
  struct Request {

  }
}
