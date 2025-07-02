//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  NetworkClient.swift
//
//  Created by Florian Mielke on 20.03.25.
//

import Foundation
import OSLog

@MainActor
class NetworkClient {
  static let shared = NetworkClient()

  @discardableResult
  static func configure(withAPIKey apiKey: String, externalID: String?) async throws -> NetworkClient {
    shared.apiKey = apiKey
    try await NetworkClient.identify(externalID: externalID)
    return shared
  }

  static func identify(externalID: String?) async throws {
    shared.identity = try await IdentityManager.shared.findOrCreate(by: externalID)
  }

  static var isConfigured: Bool {
    shared.apiKey.isNotEmpty
  }

  private static let serverHostURL = URL(string: "https://mbj-api.com")!
  private static let apiVersion = "v1"

  private var apiKey: String = ""
  private var identity: Identity?
  private let router: Router
  private let logger: Logger = Logger(subsystem: "MobileJoe", category: "NetworkClient")

  init(router: Router = DefaultRouter()) {
    self.router = router
  }
}

// MARK: - FeatureRequests
extension NetworkClient {
  func getFeatureRequests(filteredBy status: FeatureRequest.Status? = nil) async throws -> Data {
    var components = try url(for: "feature_requests")
    components.queryItems = try identifiersQueryItems()
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    return try await perform(urlRequest(for: url, httpMethod: .get))
  }

  func postVoteFeatureRequests(featureRequestID: Int) async throws -> Data {
    let components = try url(for: "feature_requests/\(featureRequestID)/vote")
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    let identifiersBodyValue = try identifiersBodyValue()
    var request = urlRequest(for: url, httpMethod: .post)
    request.httpBody = try JSONEncoder().encode(identifiersBodyValue)
    return try await perform(request)
  }
}

// MARK: - Helper
extension NetworkClient {
  private func identifiersBodyValue() throws -> [String: [String]] {
    guard let identifiersParameter = identity?.identifiersRepresentation else { throw MobileJoeError.unknownIdentity }
    return ["identifiers": identifiersParameter]
  }

  private func identifiersQueryItems() throws -> [URLQueryItem] {
    guard let identifiers = identity?.identifiersRepresentation else { throw MobileJoeError.unknownIdentity }
    return identifiers.map { URLQueryItem(name: "identifiers[]", value: $0) }
  }

  private func perform(_ request: URLRequest) async throws -> Data {
    guard NetworkClient.isConfigured else { throw MobileJoeError.notConfigured }
    let response = try await router.perform(request)
    return response.0
  }

  private func urlRequest(for url: URL, httpMethod: HTTPMethod) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(SystemInfo.frameworkVersion, forHTTPHeaderField: "X-Version")
    request.setValue(SystemInfo.deviceVersion, forHTTPHeaderField: "X-Platform-Device")
    request.setValue(SystemInfo.systemVersion, forHTTPHeaderField: "X-Platform-Version")
    request.setValue(SystemInfo.appVersion, forHTTPHeaderField: "X-Client-Version")
    request.setValue(SystemInfo.buildVersion, forHTTPHeaderField: "X-Client-Build-Version")
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
  enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
  }
}
