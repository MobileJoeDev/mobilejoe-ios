//
//  Copyright Florian Mielke. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestListView.swift
//
//  Created by Florian on 20.03.25.
//

import SwiftUI
import MobileJoe

public struct FeatureRequestListView: View {
  let joe: MobileJoe
  
  @Environment(\.dismiss) private var dismiss
  @State private var error: Error? = nil
  
  public var body: some View {
    NavigationView {
      List {
        ForEach(joe.featureRequests) { feature in
          FeatureRequestListRow(feature: feature) { vote($0) }
        }
      }
      .navigationTitle(Bundle.module.localizedString(forKey: "feature-request.list.title", value: nil, table: nil))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Menu {
            Button {
              joe.sortByScore()
            } label: {
              Label(Bundle.module.localizedString(forKey:"feature-request.list.sorting.by-score", value: nil, table: nil), systemImage: "number")
            }
            Button {
              joe.sortByDate()
            } label: {
              Label(Bundle.module.localizedString(forKey:"feature-request.list.sorting.by-date", value: nil, table: nil), systemImage: "calendar")
            }
            
          } label: {
            Label(Bundle.module.localizedString(forKey:"feature-request.list.sorting", value: nil, table: nil), systemImage: "arrow.up.arrow.down")
          }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          CloseButtonToolbarItem {
            dismiss()
          }
        }
      }
    }
    .task {
      await fetchFeatureRequests()
    }
  }
  
  public init() {
    self.init(joe: .shared)
  }
  
  init(joe: MobileJoe) {
    self.joe = joe
  }
}

extension FeatureRequestListView {
  private func fetchFeatureRequests() async {
    do {
      try await joe.fetchFeatureRequests()
    } catch {
      self.error = error
    }
  }
  
  private func vote(_ feature: MobileJoe.FeatureRequest) {
    Task {
      do {
        try await joe.vote(for: feature)
      } catch {
        self.error = error
      }
    }
  }
}

#Preview {
  FeatureRequestListView(joe: MobileJoeFixture.shared)
}
