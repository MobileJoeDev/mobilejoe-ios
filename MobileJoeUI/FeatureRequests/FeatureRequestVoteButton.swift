//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestVoteButton.swift
//
//  Created by Florian on 20.06.25.
//

import SwiftUI
import MobileJoe

struct FeatureRequestVoteButton: View {
  let featureRequest: FeatureRequest
  let vote: (FeatureRequest) -> Void

  var body: some View {
    Button {
      vote(featureRequest)
    } label: {
      VStack(spacing: 4) {
        Image(systemName: "chevron.up")
          .font(.caption)
        Text(verbatim: "\(featureRequest.score)")
          .lineLimit(1)
          .minimumScaleFactor(0.5)
      }
      .foregroundStyle(foregroundColor)
      .frame(maxWidth: 32)
      .padding(8)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .stroke(strokeColor, lineWidth: 1)
          .fill(backgroundColor)
      )
    }
    .buttonStyle(.plain)
  }
}

extension FeatureRequestVoteButton {
  private var backgroundColor: Color {
    featureRequest.isVoted ? .accentColor.opacity(0.1) : .clear
  }

  private var strokeColor: Color {
    featureRequest.isVoted ? .accentColor : .secondary
  }

  private var foregroundColor: Color {
    featureRequest.isVoted ? .accentColor : .primary
  }
}


#Preview("Voted") {
  FeatureRequestVoteButton(featureRequest: .fixture(isVoted: true), vote: { _ in })
}

#Preview("Not Voted") {
  FeatureRequestVoteButton(featureRequest: .fixture(isVoted: false), vote: { _ in })
}
