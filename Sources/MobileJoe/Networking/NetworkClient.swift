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
  static func configure(withAPIKey apiKey: String, appUserID: String?) -> NetworkClient {
    shared.apiKey = apiKey
    shared.identity = Identity.appUserID
    return shared
  }

  static func identify(appUserID: String) {
    shared.identity = I
  }

  private var apiKey: String = ""
  private var identity: Identity?
  private static let serverHostURL = URL(string: "https://mbj-api.com")!
  private static let apiVersion = "v1"
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
    components.queryItems = [URLQueryItem(name: "identity", value: identity)]
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
    var request = urlRequest(for: url)
    request.httpBody = try JSONEncoder().encode(["identity": identity])
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
