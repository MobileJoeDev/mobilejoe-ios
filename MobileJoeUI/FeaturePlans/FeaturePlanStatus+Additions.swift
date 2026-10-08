// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

extension FeaturePlan.Status {
  var title: String? {
    switch self {
    case .unknown: nil
    case .open: nil
    case .underReview: String(localized: "feature-plan.status.under-review", bundle: .module)
    case .planned: String(localized: "feature-plan.status.planned", bundle: .module)
    case .inProgress: String(localized: "feature-plan.status.in-progress", bundle: .module)
    case .completed: String(localized: "feature-plan.status.completed", bundle: .module)
    case .closed: String(localized: "feature-plan.status.closed", bundle: .module)
    }
  }

  var color: Color {
    Color(hex: hexColor) ?? .accentColor
  }

  var textColor: Color {
    switch self {
    case .unknown, .closed: .statusClosedText
    case .open: .statusOpenText
    case .underReview: .statusUnderReviewText
    case .planned: .statusPlannedText
    case .inProgress: .statusInProgressText
    case .completed: .statusCompletedText
    }
  }

  private var hexColor: String {
    switch self {
    case .unknown: "#6B7280FF" // gray-500
    case .open: "#22C55EFF" // green-500
    case .underReview: "#F59E0BFF" // amber-500
    case .planned: "#3B82F6FF" // blue-500
    case .inProgress: "#8B5CF6FF" // violet-500
    case .completed: "#10B981FF" // emerald-500
    case .closed: "#6B7280FF" // gray-500
    }
  }
}
