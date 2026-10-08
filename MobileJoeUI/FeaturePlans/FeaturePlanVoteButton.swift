// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

struct FeaturePlanVoteButton: View {
  let featurePlan: FeaturePlan
  let vote: (FeaturePlan) -> Void

  @ScaledMetric private var size = 28.0

  var body: some View {
    Button {
      vote(featurePlan)
    } label: {
      VStack(spacing: 2) {
        Image(systemName: "chevron.up")
          .font(.caption2)
        Text(featurePlan.score, format: .number.notation(.compactName))
          .lineLimit(1)
          .minimumScaleFactor(0.5)
          .font(.subheadline)
      }
      .foregroundStyle(foregroundColor)
      .aspectRatio(1.0, contentMode: .fill)
      .frame(maxWidth: size)
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

extension FeaturePlanVoteButton {
  private var backgroundColor: Color {
    featurePlan.isVoted ? .accentColor.opacity(0.1) : .clear
  }

  private var strokeColor: Color {
    featurePlan.isVoted ? .accentColor : .secondary
  }

  private var foregroundColor: Color {
    featurePlan.isVoted ? .accentColor : .primary
  }
}
