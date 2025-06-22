//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestView.swift
//
//  Created by Florian on 20.06.25.
//

import SwiftUI
import MobileJoe

struct FeatureRequestView: View {
  let featureRequest: FeatureRequest

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 30) {
        HStack {
          VStack(alignment: .leading, spacing: 10) {
            Text(featureRequest.title)
              .font(.title3)
              .fontWeight(.semibold)

            HStack(spacing: 12) {
              FeatureRequestStatusView(title: featureRequest.status, color: featureRequest.statusColor)

              Text(featureRequest.createdAt, style: .date)
                .foregroundStyle(.secondary)
                .font(.caption)
            }
          }

          Spacer()
          FeatureRequestVoteButton(featureRequest: featureRequest, vote: { _ in })
        }

        Text(featureRequest.body)
      }
      .frame(maxWidth: .infinity)
      .padding(24)
    }
    .navigationTitle(String(localized: "feature-request.title", bundle: .module))
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    FeatureRequestView(featureRequest: FeatureRequestsFixture.all.all.first!)
  }
}
