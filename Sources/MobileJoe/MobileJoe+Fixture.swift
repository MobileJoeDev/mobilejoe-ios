//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestsFixture.swift
//
//  Created by Florian Mielke on 20.03.25.
//

import Foundation

public class FeatureRequestsFixture: FeatureRequests {
  public static var empty = FeatureRequestsFixture()

  public static var failedLoading = {
    let fixture = FeatureRequestsFixture()
    fixture.loadError = MobileJoeError.generic("Failed loading")
    return fixture
  }()

  public static var all: FeatureRequestsFixture {
    let fr = FeatureRequestsFixture()
    fr.all = [
      FeatureRequest(
        id: 1,
        title: "Import holidays from calendar",
        body: "Choose an iOS calendar to automatically import and sync holidays in WorkTimes.",
        score: 10,
        statusIdentifier: "open",
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 17, hour: 12)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 12)!,
        isVoted: true
      ),
      FeatureRequest(
        id: 2,
        title: "Cloud Sync",
        body: "Sync records and accounts via iCloud on multiple devices.",
        score: 33,
        statusIdentifier: "planned",
        createdAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 13)!,
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 18, hour: 13)!,
        isVoted: false
      ),
    ]
    return fr
  }

  private var loadError: Error? = nil
  public override func load() async throws {
    if let loadError { throw loadError }
  }

  public override func vote(_ featureRequest: FeatureRequest) async throws {
  }
}

extension FeatureRequest {
  public static func fixture(isVoted: Bool) -> FeatureRequest {
    FeatureRequest(
      id: 1,
      title: "Do not change the view date when changing the app",
      body: """
      I’m editing old time entries form 1 year ago. For that, sometimes I need to change to another app to get some information about that date. When I change back to the worktimes app, it automatically returns to the current date, so I have to scroll back manually to the date I was editing and hope that I did not forget the information in the meantime so that I would have to change back to the other app (infinite loop 🙂).
      
      As there is already a button to return to the current date, I don’t see much of a reason to change the shown date automatically when switching the app. My suggestion is to remove this “feature” or make it optional.
      """,
      score: 10,
      statusIdentifier: "open",
      createdAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 11)!,
      updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 16, hour: 11)!,
      isVoted: isVoted
    )
  }
}
