//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  MobileJoe.swift
//
//  Created by Florian Mielke on 20.03.25.
//

import Foundation

@MainActor
@Observable
public class MobileJoe {
  public static func configure(withAPIKey apiKey: String, appUserID: String? = nil) {
    Task {
      try? await NetworkClient.configure(withAPIKey: apiKey, externalID: appUserID)
    }
  }

  public static func identify(appUserID: String) {
    Task {
      try? await NetworkClient.identify(externalID: appUserID)
    }
  }
}
