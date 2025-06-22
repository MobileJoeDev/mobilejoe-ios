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

struct FeatureRequestStatusView: View {
  let title: String
  let color: Color

  var body: some View {
    Text(title)
      .font(.caption)
      .fontWeight(.medium)
      .foregroundStyle(color)
      .padding(.vertical, 2)
      .padding(.horizontal, 6)
      .background(color.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
  }
}

#Preview {
  FeatureRequestStatusView(title: "Open", color: .blue)
}
