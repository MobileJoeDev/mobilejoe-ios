//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestsFilter+Additions.swift
//
//  Created by Florian Mielke on 02.07.25.
//

import Foundation
import MobileJoe

extension FeatureRequests.Filter {
  var title: String {
    switch self {
    case .all: String(localized: "feature-request.filter.all", bundle: .module)
    case .underReview: String(localized: "feature-request.filter.under-review", bundle: .module)
    case .planned: String(localized: "feature-request.filter.planned", bundle: .module)
    case .inProgress: String(localized: "feature-request.filter.in-progress", bundle: .module)
    case .completed: String(localized: "feature-request.filter.completed", bundle: .module)
    }
  }
}
