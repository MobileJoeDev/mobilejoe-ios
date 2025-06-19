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

  public static var all: FeatureRequestsFixture {
    let fr = FeatureRequestsFixture()
    fr.all = [
      FeatureRequest(
        id: 1,
        title: "Import holidays from calendar",
        body: "Choose an iOS calendar to automatically import and sync holidays in WorkTimes.",
        score: 10,
        status: "Open",
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 12)!,
        isVoted: true,
        statusHexColor: "#FF0000"
      ),
      FeatureRequest(
        id: 2,
        title: "Cloud Sync",
        body: "Sync records and accounts via iCloud on multiple devices.",
        score: 33,
        status: "Planned",
        updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 13)!,
        isVoted: false,
        statusHexColor: "#FF0000"
      ),
    ]
    return fr
  }

  public override func load() async throws {
  }

  public override func vote(_ featureRequest: FeatureRequest) async throws {
  }
}

extension FeatureRequest {
  public static func fixture(isVoted: Bool) -> FeatureRequest {
    FeatureRequest(
      id: 1,
      title: "Import holidays from calendar",
      body: "Choose an iOS calendar to automatically import and sync holidays in WorkTimes.",
      score: 10,
      status: "Open",
      updatedAt: Calendar.utc.date(year: 2025, month: 3, day: 15, hour: 11)!,
      isVoted: isVoted,
      statusHexColor: "#FF0000"
    )
  }
}
