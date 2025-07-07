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
  
  @State private var isExpanded = false
  
  var body: some View {
    Button(action: toggleExpandedState) {
      VStack(alignment: .leading, spacing: 16) {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 8) {
            Text(featureRequest.title)
              .font(.title3)
              .fontWeight(.semibold)
              .multilineTextAlignment(.leading)
              .lineLimit(nil)
              .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 12) {
              FeatureRequestStatusView(status:  featureRequest.status)
              Text(featureRequest.createdAt, style: .date)
                .foregroundStyle(.secondary)
                .font(.caption)
            }
          }
          
          Spacer()
          FeatureRequestVoteButton(featureRequest: featureRequest, vote: vote)
        }
        
        Text(featureRequest.body)
          .lineLimit(isExpanded ? nil : 3)
      }
      .foregroundStyle(Color.primary)
    }
    .padding(.vertical, 10)
    .frame(maxWidth: .infinity)
  }
}

extension FeatureRequestListRow {
  private func toggleExpandedState() {
    isExpanded.toggle()
  }
}

#Preview("Voted") {
  List {
    FeatureRequestListRow(featureRequest: .fixture(isVoted: true), vote: { _ in })
    FeatureRequestListRow(featureRequest: .fixture(isVoted: false, score: 1_030), vote: { _ in })
  }
}
