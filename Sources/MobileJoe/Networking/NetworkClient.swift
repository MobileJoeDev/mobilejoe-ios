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
  func getFeatureRequests(filterBy statuses: [FeatureRequest.Status]?, sort sorting: FeatureRequest.Sorting) async throws -> Data {
    var components = try url(for: "feature_requests")
    components.queryItems = statusesQueryItems(for: statuses) + sortQueryItems(for: sorting)
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    let request = try urlRequest(for: url, httpMethod: .get)
    return try await perform(request)
  }

  func postVoteFeatureRequests(featureRequestID: Int) async throws -> Data {
    let components = try url(for: "feature_requests/\(featureRequestID)/vote")
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    let request = try urlRequest(for: url, httpMethod: .post)
    return try await perform(request)
  }

  private func statusesQueryItems(for statuses: [FeatureRequest.Status]?) -> [URLQueryItem] {
    statuses?.map { URLQueryItem(name: "statuses[]", value: $0.rawValue) } ?? []
  }

  private func sortQueryItems(for sorting: FeatureRequest.Sorting) -> [URLQueryItem] {
    [URLQueryItem(name: "sort", value: sorting.rawValue)]
  }
}

// MARK: - Helper
extension NetworkClient {
  private func perform(_ request: URLRequest) async throws -> Data {
    guard NetworkClient.isConfigured else { throw MobileJoeError.notConfigured }
    let response = try await router.perform(request)
    return response.0
  }

  private func urlRequest(for url: URL, httpMethod: HTTPMethod) throws -> URLRequest {
    guard let identity else { throw MobileJoeError.unknownIdentity }
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(SystemInfo.frameworkVersion, forHTTPHeaderField: "X-Version")
    request.setValue(SystemInfo.deviceVersion, forHTTPHeaderField: "X-Platform-Device")
    request.setValue(SystemInfo.systemVersion, forHTTPHeaderField: "X-Platform-Version")
    request.setValue(SystemInfo.appVersion, forHTTPHeaderField: "X-Client-Version")
    request.setValue(SystemInfo.buildVersion, forHTTPHeaderField: "X-Client-Build-Version")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue(identity.anonymousID, forHTTPHeaderField: "X-Anonymous-Identifier")
    if let externalID = identity.externalID {
      request.setValue(externalID, forHTTPHeaderField: "X-External-Identifier")
    }
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
