// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import MobileJoeResources

public enum MobileJoeError: LocalizedError, CustomNSError, CustomDebugStringConvertible {
  case notConfigured
  case unknownIdentity
  case invalidURL(components: URLComponents)
  case invalidHTTPResponse
  case httpFailure(statusCode: Int, method: String, path: String)
  case invalidAppUserID
  case invalidAPIKey

  public var errorDescription: String? {
    switch self {
    case .notConfigured: String(localized: "sdk.error.not-configured.description", bundle: Resources.bundle)
    case .unknownIdentity: String(localized: "sdk.error.unknown-identity.description", bundle: Resources.bundle)
    case .invalidURL: String(localized: "sdk.error.invalid-url.description", bundle: Resources.bundle)
    case .invalidHTTPResponse: String(localized: "sdk.error.invalid-http-response.description", bundle: Resources.bundle)
    case .httpFailure: String(localized: "sdk.error.http-failure.description", bundle: Resources.bundle)
    case .invalidAppUserID: String(localized: "sdk.error.invalid-app-user-id.description", bundle: Resources.bundle)
    case .invalidAPIKey: String(localized: "sdk.error.invalid-api-key.description", bundle: Resources.bundle)
    }
  }

  public static let errorDomain = "MobileJoeError"

  // Published monitoring identifiers: never renumber or reuse these values.
  public var errorCode: Int {
    switch self {
    case .notConfigured: 1001
    case .unknownIdentity: 1002
    case .invalidURL: 1003
    case .invalidHTTPResponse: 1004
    case .httpFailure: 1005
    case .invalidAppUserID: 1006
    case .invalidAPIKey: 1007
    }
  }

  public var errorUserInfo: [String: Any] {
    var userInfo: [String: Any] = [:]
    userInfo[NSLocalizedDescriptionKey] = errorDescription
    if case let .httpFailure(statusCode, method, path) = self {
      userInfo["statusCode"] = statusCode
      userInfo["method"] = method
      userInfo["path"] = path
    }
    return userInfo
  }

  public var debugDescription: String {
    switch self {
    case .notConfigured: "MobileJoeError.notConfigured"
    case .unknownIdentity: "MobileJoeError.unknownIdentity"
    case .invalidURL: "MobileJoeError.invalidURL"
    case .invalidHTTPResponse: "MobileJoeError.invalidHTTPResponse"
    case let .httpFailure(statusCode, method, path): "MobileJoeError.httpFailure: \(method) \(path) returned HTTP \(statusCode)"
    case .invalidAppUserID: "MobileJoeError.invalidAppUserID"
    case .invalidAPIKey: "MobileJoeError.invalidAPIKey"
    }
  }
}
