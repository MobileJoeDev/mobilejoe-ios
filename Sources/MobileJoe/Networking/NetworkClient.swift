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

let sharedNetworkClient = NetworkClient()

actor NetworkClient {
  // No static shared property to satisfy Swift 6 strict concurrency

  @discardableResult
  static func configure(withAPIKey apiKey: String, externalID: String?) async throws -> NetworkClient {
    try await sharedNetworkClient.configure(withAPIKey: apiKey, externalID: externalID)
  }

  static func identify(externalID: String?) async throws {
    try await sharedNetworkClient.setIdentity(externalID: externalID)
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

  // MARK: - Actor-isolated helpers
  private func configure(withAPIKey apiKey: String, externalID: String?) async throws -> NetworkClient {
    self.apiKey = apiKey
    try await setIdentity(externalID: externalID)
    return self
  }

  private func setIdentity(externalID: String?) async throws {
    self.identity = try await IdentityManager.shared.findOrCreate(by: externalID)
  }
}

// MARK: - FeatureRequests
extension NetworkClient {
  func getFeatureRequests(filterBy statuses: [FeatureRequest.Status]?, sort sorting: FeatureRequest.Sorting, search: String?, page: Int) async throws -> (data: Data, pagination: Pagination) {
    var components = try url(for: "feature_requests")
    components.queryItems = searchQueryItems(for: search) + statusesQueryItems(for: statuses) + sortQueryItems(for: sorting) + pageQueryItems(for: page)
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    let request = try urlRequest(for: url, httpMethod: .get)
    let result = try await perform(request)
    let pagination = Pagination(urlResponse: result.response)
    return (result.data, pagination)
  }

  func postVoteFeatureRequests(featureRequestID: Int) async throws -> Data {
    let components = try url(for: "feature_requests/\(featureRequestID)/vote")
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    let request = try urlRequest(for: url, httpMethod: .post)
    return try await perform(request).data
  }

  private func statusesQueryItems(for statuses: [FeatureRequest.Status]?) -> [URLQueryItem] {
    statuses?.map { URLQueryItem(name: "statuses[]", value: $0.rawValue) } ?? []
  }

  private func sortQueryItems(for sorting: FeatureRequest.Sorting) -> [URLQueryItem] {
    [URLQueryItem(name: "sort", value: sorting.rawValue)]
  }

  private func searchQueryItems(for search: String?) -> [URLQueryItem] {
    guard let search, search.isNotEmpty else { return [] }
    return [URLQueryItem(name: "search", value: "\(search)")]
  }

  private func pageQueryItems(for page: Int) -> [URLQueryItem] {
    [URLQueryItem(name: "page", value: "\(page)")]
  }
}

// MARK: - Helper
extension NetworkClient {
  private func perform(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
    guard apiKey.isNotEmpty else { throw MobileJoeError.notConfigured }
    return try await router.perform(request)
  }

  private func urlRequest(for url: URL, httpMethod: HTTPMethod) throws -> URLRequest {
    guard let identity else { throw MobileJoeError.unknownIdentity }
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(SystemInfo.frameworkVersion, forHTTPHeaderField: "Framework-Version")
    request.setValue(SystemInfo.deviceVersion, forHTTPHeaderField: "Device-Version")
    request.setValue(SystemInfo.systemVersion, forHTTPHeaderField: "System-OS-Version")
    request.setValue(SystemInfo.appVersion, forHTTPHeaderField: "App-Version")
    request.setValue(SystemInfo.buildVersion, forHTTPHeaderField: "App-Build-Version")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue(identity.anonymousID, forHTTPHeaderField: "Identity-Anonymous-ID")
    if let externalID = identity.externalID {
      request.setValue(externalID, forHTTPHeaderField: "Identity-External-ID")
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
