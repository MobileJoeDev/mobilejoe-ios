//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestSorting+Additions.swift
//
//  Created by Florian Mielke on 08.05.25.
//

import Foundation
import MobileJoe

extension FeatureRequests.Sorting {
  var title: String {
    switch self {
    case .byNewest: String(localized: "feature-request.list.sorting.by-newest", bundle: .module)
    case .byScore: String(localized: "feature-request.list.sorting.by-score", bundle: .module)
    }
  }

  var systemImage: String {
    switch self {
    case .byNewest: "calendar"
    case .byScore: "number"
    }
  }
}
