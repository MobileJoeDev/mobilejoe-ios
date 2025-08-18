//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequest+Status.swift
//
//  Created by Florian Mielke on 22.06.25.
//

import Foundation

extension FeatureRequest {
  public enum Status: String {
    case unknown = "unknown"
    case open = "open"
    case underReview = "under_review"
    case planned = "planned"
    case inProgress = "in_progress"
    case completed = "completed"
    case closed = "closed"
  }
}
