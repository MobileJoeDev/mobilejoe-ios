//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  ContentUnavailableFailureView.swift
//
//  Created by Florian on 20.06.25.
//

import SwiftUI

struct ContentUnavailableFailureView: View {
  @ScaledMetric private var joeWidth = 90.0

  var body: some View {
    ContentUnavailableView {
      Image(.joeSignSorry)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: joeWidth)
        .foregroundStyle(Color.black)
      Text("content-unavailable.failure.title", bundle: .module)
        .fontWeight(.bold)
        .padding(.top)
    } description: {
      Text("content-unavailable.failure.text", bundle: .module)
    }
  }
}

#Preview {
  ContentUnavailableFailureView()
}
