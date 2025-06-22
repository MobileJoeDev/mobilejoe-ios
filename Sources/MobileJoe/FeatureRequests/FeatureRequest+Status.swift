//
//  File.swift
//  MobileJoe
//
//  Created by Florian on 22.06.25.
//

import Foundation

extension FeatureRequest {
  public enum Status: String {
    case open = "open"
    case underReview = "under_review"
    case planned = "planned"
    case inProgress = "in_progress"
    case completed = "completed"
    case closed = "closed"
  }
}
