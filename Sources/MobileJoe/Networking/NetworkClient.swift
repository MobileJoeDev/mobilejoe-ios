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

class NetworkClient {
  static let shared = NetworkClient()

  @discardableResult
  static func configure(withAPIKey apiKey: String, externalID: String?, debugMode: Bool = false) async throws -> NetworkClient {
    shared.apiKey = apiKey
    shared.isDebugMode = debugMode
    try await NetworkClient.identify(externalID: externalID)
    return shared
  }

  static func identify(externalID: String?) async throws {
    shared.identity = try await IdentityManager.shared.findOrCreate(by: externalID)
    try await shared.postIdentify()
  }

  static var isConfigured: Bool {
    shared.apiKey.isNotEmpty
  }

  private static let serverHostURL = URL(string: "https://mbj-api.com")!
  private static let apiVersion = "v1"

  private var isDebugMode: Bool
  private var apiKey: String
  private var identity: Identity?
  private let router: Router
  private let logger: Logger = Logger(subsystem: "MobileJoe", category: "NetworkClient")

  init(router: Router = DefaultRouter(), isDebugMode: Bool = false, apiKey: String = "", identity: Identity? = nil) {
    self.router = router
    self.isDebugMode = isDebugMode
    self.apiKey = apiKey
    self.identity = identity
  }
}

// MARK: - Identify
extension NetworkClient {
  func postIdentify() async throws {
    let components = try url(for: "identify")
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    let request = try urlRequest(for: url, httpMethod: .post)
    _ = try await perform(request)
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

// MARK: - Alerts
extension NetworkClient {
  func getAlerts() async throws -> Data {
    let components = try url(for: "alerts")
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    let request = try urlRequest(for: url, httpMethod: .get)
    let result = try await perform(request)
    return result.data
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
    request.setValue(SystemInfo.deviceModel, forHTTPHeaderField: "Device-Model")
    request.setValue(SystemInfo.osName, forHTTPHeaderField: "OS-Name")
    request.setValue(SystemInfo.osVersion, forHTTPHeaderField: "OS-Version")
    request.setValue(SystemInfo.appVersion, forHTTPHeaderField: "App-Version")
    request.setValue(SystemInfo.appBuildVersion, forHTTPHeaderField: "App-Build-Version")
    request.setValue(SystemInfo.languageCode, forHTTPHeaderField: "Language-Code")
    request.setValue("\(isDebugMode)", forHTTPHeaderField: "Debug-Mode")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue(identity.anonymousID, forHTTPHeaderField: "Identity-Anonymous-ID")
    request.setValue(identity.deviceID, forHTTPHeaderField: "Identity-Device-ID")
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
