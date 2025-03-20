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
  static func configure(withAPIKey apiKey: String) -> NetworkClient {
    shared.apiKey = apiKey
    return shared
  }

  private static let serverHostURL = URL(string: "https://api.mobilejoe.dev")!
  private static let apiVersion = "v1"

  private var apiKey: String = ""
  private var appUserID: String = ""
}

extension NetworkClient {
  enum Request {
    case getFeatureRequests(appUserID: String)
    case postVoteFeatureRequests(featureRequestID: String)

    var pathComponent: String {
      switch self {
      case .getFeatureRequests(let appUserID): "/feature_requests?user_id?=\(appUserID.escaped)"
      case .postVoteFeatureRequests(let featureRequestID): "feature_requests/\(featureRequestID.escaped)/vote"
      }
    }
  }
}
