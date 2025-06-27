//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestStatusView.swift
//
//  Created by Florian on 20.06.25.
//

import SwiftUI
import MobileJoe

struct FeatureRequestStatusView: View {
  let status: FeatureRequest.Status

  var body: some View {
    if let title = status.title {
      Text(title)
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(status.color)
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .background(status.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
  }
}

#Preview {
  FeatureRequestStatusView(status: .unknown)
  FeatureRequestStatusView(status: .open)
  FeatureRequestStatusView(status: .underReview)
  FeatureRequestStatusView(status: .planned)
  FeatureRequestStatusView(status: .inProgress)
  FeatureRequestStatusView(status: .completed)
  FeatureRequestStatusView(status: .closed)
}
