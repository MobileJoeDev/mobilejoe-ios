// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import OSLog

protocol APIClient {
  func getAlerts() async throws -> Data
  func getFAQs() async throws -> Data
  func getFeaturePlans(filterBy statuses: [FeaturePlan.Status]?, sort sorting: FeaturePlan.Sorting, search: String?, page: Int) async throws -> (data: Data, pagination: Pagination)
  func getFeaturePlan(id: Int) async throws -> Data
  func postFeaturePlanVote(featurePlanID: Int) async throws -> Data
  var isDebugModeEnabled: Bool { get }
}

class NetworkClient: APIClient {
  static let shared = NetworkClient()

  func configure(withAPIKey apiKey: String, externalID: String?, debugMode: Bool = false) async throws {
    try validate(externalID: externalID)
    if let configurationTask {
      return try await configurationTask.value
    }

    self.apiKey = ""
    let task = identityOperations.enqueue(.configuration) {
      do {
        try await self.synchronizeIdentity(externalID: externalID, apiKey: apiKey, debugMode: debugMode)
        self.apiKey = apiKey
        self.isDebugMode = debugMode
        self.logger.debug("🦫 Joe says: SDK configured successfully.")
      } catch {
        self.configurationTask = nil
        throw error
      }
    }
    configurationTask = task
    try await task.value
  }

  static var isConfigured: Bool {
    shared.apiKey.isNotEmpty
  }

  private static let serverHostURL = URL(string: "https://mbj-api.com")!
  private static let apiVersion = "v1"

  private var isDebugMode: Bool
  private var apiKey: String
  private let identityOperations = IdentityOperationQueue()
  private var configurationTask: Task<Void, Error>?
  private let identityManager: IdentityManager
  private let router: Router
  private let logger = Logger(category: "NetworkClient")

  init(router: Router = DefaultRouter(), isDebugMode: Bool = false, apiKey: String = "", identityManager: IdentityManager = .shared) {
    self.router = router
    self.isDebugMode = isDebugMode
    self.apiKey = apiKey
    self.identityManager = identityManager
  }

  var isDebugModeEnabled: Bool {
    isDebugMode
  }
}

// MARK: - Identify
extension NetworkClient {
  func identify(externalID: String?) async throws {
    try validate(externalID: externalID)
    let configuration = configurationTask
    guard configuration != nil || apiKey.isNotEmpty else { throw MobileJoeError.notConfigured }
    let task = identityOperations.enqueue(.identification(externalID)) {
      if let configuration { try await configuration.value }
      try await self.synchronizeIdentity(externalID: externalID, apiKey: self.apiKey, debugMode: self.isDebugMode)
    }
    try await task.value
  }

  func logout() async throws {
    let configuration = configurationTask
    let task = identityOperations.enqueue(.logout) {
      if let configuration { try await configuration.value }
      _ = try await self.identityManager.logout()
    }
    try await task.value
  }

  private func synchronizeIdentity(externalID: String?, apiKey: String, debugMode: Bool) async throws {
    guard apiKey.isNotEmpty else { throw MobileJoeError.notConfigured }
    guard let identity = try await identityManager.prepareIdentity(for: externalID) else { return }
    try await postIdentify(identity: identity, apiKey: apiKey, debugMode: debugMode)
    try await identityManager.commit(identity)
  }

  private func validate(externalID: String?) throws {
    if let externalID, externalID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      throw MobileJoeError.invalidAppUserID
    }
  }

  private func postIdentify(identity: Identity, apiKey: String, debugMode: Bool) async throws {
    let components = try url(for: "identify")
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    let request = try urlRequest(for: url, httpMethod: .post, identity: identity, apiKey: apiKey, debugMode: debugMode)
    _ = try await router.perform(request)
  }

}

// MARK: - FeaturePlans
extension NetworkClient {
  func getFeaturePlans(filterBy statuses: [FeaturePlan.Status]?, sort sorting: FeaturePlan.Sorting, search: String?, page: Int) async throws -> (data: Data, pagination: Pagination) {
    var components = try url(for: "feature_plans")
    components.queryItems = searchQueryItems(for: search) + statusesQueryItems(for: statuses) + sortQueryItems(for: sorting) + pageQueryItems(for: page)
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    let request = try urlRequest(for: url, httpMethod: .get)
    let result = try await perform(request)
    let pagination = Pagination(urlResponse: result.response)
    return (result.data, pagination)
  }

  func getFeaturePlan(id: Int) async throws -> Data {
    let components = try url(for: "feature_plans/\(id)")
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    let request = try urlRequest(for: url, httpMethod: .get)
    return try await perform(request).data
  }

  func postFeaturePlanVote(featurePlanID: Int) async throws -> Data {
    let components = try url(for: "feature_plans/\(featurePlanID)/vote")
    guard let url = components.url else { throw MobileJoeError.invalidURL(components: components) }
    let request = try urlRequest(for: url, httpMethod: .post)
    return try await perform(request).data
  }

  private func statusesQueryItems(for statuses: [FeaturePlan.Status]?) -> [URLQueryItem] {
    statuses?.map { URLQueryItem(name: "statuses[]", value: $0.rawValue) } ?? []
  }

  private func sortQueryItems(for sorting: FeaturePlan.Sorting) -> [URLQueryItem] {
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

// MARK: - FAQs
extension NetworkClient {
  func getFAQs() async throws -> Data {
    let components = try url(for: "faqs")
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
    guard apiKey.isNotEmpty else { throw MobileJoeError.notConfigured }
    guard let identity = identityManager.currentIdentity else { throw MobileJoeError.unknownIdentity }
    return try urlRequest(for: url, httpMethod: httpMethod, identity: identity, apiKey: apiKey, debugMode: isDebugMode)
  }

  private func urlRequest(for url: URL, httpMethod: HTTPMethod, identity: Identity, apiKey: String, debugMode: Bool) throws -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(SystemInfo.frameworkVersion, forHTTPHeaderField: "Framework-Version")
    request.setValue(SystemInfo.deviceModel, forHTTPHeaderField: "Device-Model")
    request.setValue(SystemInfo.osName, forHTTPHeaderField: "OS-Name")
    request.setValue(SystemInfo.osVersion, forHTTPHeaderField: "OS-Version")
    request.setValue(SystemInfo.appVersion, forHTTPHeaderField: "App-Version")
    request.setValue(SystemInfo.appBuildVersion, forHTTPHeaderField: "App-Build-Version")
    request.setValue(SystemInfo.preferredLanguages, forHTTPHeaderField: "Preferred-Languages")
    request.setValue("\(debugMode)", forHTTPHeaderField: "Debug-Mode")
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
