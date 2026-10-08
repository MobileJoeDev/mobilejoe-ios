// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
@testable import MobileJoe

extension FeaturePlan {
  static func fixture(isVoted: Bool, score: Int = 10) -> FeaturePlan {
    FeaturePlan(
      id: 1,
      title: "Do not change the view date when changing the app",
      body: """
      I'm editing old time entries form 1 year ago. For that, sometimes I need to change to another app to get some information about that date. When I change back to the worktimes app, it automatically returns to the current date, so I have to scroll back manually to the date I was editing and hope that I did not forget the information in the meantime so that I would have to change back to the other app (infinite loop 🙂).

      As there is already a button to return to the current date, I don't see much of a reason to change the shown date automatically when switching the app. My suggestion is to remove this "feature" or make it optional.
      """,
      score: score,
      status: .inProgress,
      createdAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 11)!,
      updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 16, hour: 11)!,
      isVoted: isVoted
    )
  }
}
