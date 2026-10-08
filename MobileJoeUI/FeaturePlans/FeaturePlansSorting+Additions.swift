// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import MobileJoe

extension FeaturePlan.Sorting {
  var title: String {
    switch self {
    case .byNewest: String(localized: "feature-plan.list.sorting.by-newest", bundle: .module)
    case .byScore: String(localized: "feature-plan.list.sorting.by-score", bundle: .module)
    }
  }

  var systemImage: String {
    switch self {
    case .byNewest: "calendar"
    case .byScore: "number"
    }
  }
}
