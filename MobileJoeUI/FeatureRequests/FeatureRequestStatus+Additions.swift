//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestStatus+Additions.swift
//
//  Created by Florian Mielke on 02.04.25.
//

import SwiftUI
import MobileJoe

extension FeatureRequest.Status {
  var title: String {
    switch self {
    case .open: String(localized: "feature-request.status.open", bundle: .module)
    case .underReview: String(localized: "feature-request.status.under-review", bundle: .module)
    case .planned: String(localized: "feature-request.status.planned", bundle: .module)
    case .inProgress: String(localized: "feature-request.status.in-progress", bundle: .module)
    case .completed: String(localized: "feature-request.status.completed", bundle: .module)
    case .closed: String(localized: "feature-request.status.closed", bundle: .module)
    }
  }

  var color: Color {
    Color(hex: hexColor) ?? .accentColor
  }

  private var hexColor: String {
    switch self {
    case .open: "#22C55EFF" // green-500
    case .underReview: "#F59E0BFF" // amber-500
    case .planned: "#3B82F6FF" // blue-500
    case .inProgress: "#8B5CF6FF" // violet-500
    case .completed: "#10B981FF" // emerald-500
    case .closed: "#6B7280FF" // gray-500
    }
  }
}
