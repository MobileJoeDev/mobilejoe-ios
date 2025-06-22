//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestListRow.swift
//
//  Created by Florian Mielke on 20.03.25.
//

import SwiftUI
import MobileJoe

struct FeatureRequestListRow: View {
  let featureRequest: FeatureRequest
  let vote: (FeatureRequest) -> Void

  var body: some View {
    HStack(alignment: .top, spacing: 6) {
      VStack(alignment: .leading, spacing: 12) {
        Text(featureRequest.title)
          .fontWeight(.medium)
        Text(featureRequest.body)
          .lineLimit(3)
          .font(.subheadline)

        FeatureRequestStatusView(
          title: featureRequest.status.localizedCapitalized,
          color: featureRequest.statusColor
        )
        .padding(.top, 6)
      }

      Spacer()
      FeatureRequestVoteButton(featureRequest: featureRequest, vote: vote)
    }
    .padding(.vertical, 8)
    .frame(maxWidth: .infinity)
  }
}

#Preview("Voted") {
  List {
    FeatureRequestListRow(featureRequest: .fixture(isVoted: true), vote: { _ in })
    FeatureRequestListRow(featureRequest: .fixture(isVoted: false), vote: { _ in })
  }
}
