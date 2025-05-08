//
//  Copyright Florian Mielke. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequests+Configuration.swift
//
//  Created by Florian on 08.05.25.
//

import Foundation
import MobileJoe

extension FeatureRequestListView {
  public struct Configuration {
    let recipients: [String]
    let subject: String?
    let body: String?

    public init(recipients: [String], subject: String? = nil, body: String? = nil) {
      self.recipients = recipients
      self.subject = subject
      self.body = body
    }

    public var mailToURL: URL? {
      var components = URLComponents()
      components.scheme = "mailto"
      components.path = recipients.joined(separator: ",")
      components.queryItems = [
        URLQueryItem(name: "subject", value: subject ?? String(localized: "feature-request-configuration.subject", bundle: .module)),
        URLQueryItem(name: "body", value: body ?? "")
      ]
      return components.url
    }
  }
}
