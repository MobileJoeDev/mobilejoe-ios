// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import MobileJoe

extension FeaturePlans.Filter {
  var title: String {
    switch self {
    case .all: String(localized: "feature-plan.filter.all", bundle: .module)
    case .underReview: String(localized: "feature-plan.filter.under-review", bundle: .module)
    case .planned: String(localized: "feature-plan.filter.planned", bundle: .module)
    case .inProgress: String(localized: "feature-plan.filter.in-progress", bundle: .module)
    case .completed: String(localized: "feature-plan.filter.completed", bundle: .module)
    case .roadmap: String(localized: "feature-plan.filter.roadmap", bundle: .module)
    }
  }

  var systemImage: String {
    switch self {
    case .all: "circle"
    case .underReview: "circle.dashed"
    case .planned: "clock"
    case .inProgress: "sleep"
    case .completed: "checkmark.circle"
    case .roadmap: "calendar.day.timeline.left"
    }
  }
}
