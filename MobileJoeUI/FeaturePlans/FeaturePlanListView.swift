// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

struct FeaturePlanListView: View {
  @State var featurePlans: FeaturePlans
  let configuration: FeaturePlansView.Configuration
  let presentationMode: PresentationMode

  @Environment(\.dismiss) private var dismiss
  @State private var error: Error? = nil
  @State private var unknownFeaturePlanError: FeaturePlansError? = nil
  @State private var showUnknownFeaturePlanErrorAlert = false
  @State private var isLoading = true
  @State private var searchText: String = ""

  @State private var selectedFeaturePlanID: Int?
  @State private var selection: FeaturePlan?

  var body: some View {
    List {
      ForEach(featurePlans.all) { featurePlan in
        FeaturePlanListRow(featurePlan: featurePlan) { vote($0) }
          .onTapGesture {
            selection = featurePlan
          }
          .onAppear {
            loadMoreIfNeeded(featurePlan)
          }
      }
    }
    .sheet(item: $selection) { featurePlan in
      NavigationStack {
        FeaturePlanDetailView(featurePlan: featurePlan, featurePlans: featurePlans)
      }
    }
    .refreshable {
      await reload()
    }
    .overlay {
      Overlay()
    }
    .alert(
      isPresented: $showUnknownFeaturePlanErrorAlert,
      error: unknownFeaturePlanError,
      actions: { }
    )
    .navigationTitle(String(localized: "feature-plan.list.title", bundle: .module))
    .navigationBarTitleDisplayMode(.inline)
    .toolbar(content: ToolbarItems)
    .searchable(text: $searchText)
    .onChange(of: searchText) { _, newValue in
      search(for: newValue)
    }
    .task {
      await reload()
      await openFeaturePlanIDIfNeeded()
    }
  }

  init(
    featurePlans: FeaturePlans,
    presentationMode: PresentationMode,
    configuration: FeaturePlansView.Configuration,
    selectedFeaturePlanID: Int? = nil
  ) {
    _featurePlans = State<FeaturePlans>(wrappedValue: featurePlans)
    self.presentationMode = presentationMode
    self.configuration = configuration
    _selectedFeaturePlanID = State<Int?>(wrappedValue: selectedFeaturePlanID)
  }
}

extension FeaturePlanListView {
  @ToolbarContentBuilder
  private func ToolbarItems() -> some ToolbarContent {
    if presentationMode == .asSheet {
      ToolbarItem(placement: .topBarTrailing) {
        CloseButtonToolbarItem {
          dismiss()
        }
      }
    }

    ToolbarItem(placement: .bottomBar) {
      ActionMenu()
    }

    if #available(iOS 26.0, *) {
      ToolbarSpacer(.flexible, placement: .bottomBar)
      DefaultToolbarItem(kind: .search, placement: .bottomBar)
      ToolbarSpacer(.flexible, placement: .bottomBar)
    } else {
      ToolbarItem(placement: .bottomBar) {
        Spacer()
      }
    }

    if let mailToURL = configuration.mailToURL {
      ToolbarItem(placement: .bottomBar) {
        Link(destination: mailToURL) {
          Label {
            Text("feature-plan.contact-mail-to", bundle: .module)
          } icon: {
            Image(systemName: "square.and.pencil")
          }
        }
      }
    }
  }

  @ViewBuilder
  private func Overlay() -> some View {
    if isLoading {
      ProgressView(String(localized: "feature-plan.list.loading", bundle: .module))
    } else if error != nil {
      JoeContentUnavailableFailureView()
    } else if featurePlans.all.isEmpty {
      JoeContentUnavailableView(title: "feature-plan-list.no-items.title", text: "feature-plan-list.no-items.text")
    }
  }

  private func ActionMenu() -> some View {
    Menu {
      Picker(String(localized: "feature-plan.list.sorting", bundle: .module), selection: $featurePlans.sorting) {
        ForEach(FeaturePlan.Sorting.allCases) { sorting in
          Label(sorting.title, systemImage: sorting.systemImage)
        }
      }

      Picker(String(localized: "feature-plan.list.filtering", bundle: .module), selection: $featurePlans.filtering) {
        ForEach(FeaturePlans.Filter.allCases) { filter in
          Label(filter.title, systemImage: filter.systemImage)
        }
      }
    } label: {
      Image(systemName: actionMenuSystemImage)
        .foregroundStyle(featurePlans.filtering == .all ? Color.primary : Color.accentColor)
    }
  }

  private var actionMenuSystemImage: String {
    if featurePlans.filtering == .all {
      if #available(iOS 26.0, *) {
        return "line.3.horizontal.decrease"
      } else {
        return "line.3.horizontal.decrease.circle"
      }
    } else {
      if #available(iOS 26.0, *) {
        return "line.3.horizontal.decrease"
      } else {
        return "line.3.horizontal.decrease.circle.fill"
      }
    }
  }
}

extension FeaturePlanListView {
  private func loadMoreIfNeeded(_ featurePlan: FeaturePlan) {
    guard featurePlan == featurePlans.all.last else { return }
    Task {
      await load()
    }
  }

  private func load() async {
    defer { isLoading = false }
    do {
      resetError()
      try await featurePlans.load()
    } catch {
      self.error = error
    }
  }

  private func reload() async {
    defer { isLoading = false }
    do {
      resetError()
      try await featurePlans.reload()
    } catch {
      self.error = error
    }
  }

  private func openFeaturePlanIDIfNeeded() async {
    guard hasNoErrors else { return }
    do {
      try await loadFeaturePlanIfNeeded()
    } catch let error as FeaturePlansError {
      switch error {
      case .unknownFeaturePlan:
        unknownFeaturePlanError = error
        showUnknownFeaturePlanErrorAlert = true
      }
    } catch {
    }
  }

  private var hasNoErrors: Bool {
    error == nil
  }

  private func loadFeaturePlanIfNeeded() async throws {
    guard let selectedFeaturePlanID else { return }
    selection = try await featurePlans.featurePlan(id: selectedFeaturePlanID)
    self.selectedFeaturePlanID = nil
  }

  private func vote(_ featurePlan: FeaturePlan) {
    resetError()
    Task {
      do {
        try await featurePlans.vote(featurePlan)
      } catch {
        self.error = error
      }
    }
  }

  private func search(for text: String) {
    Task {
      try? await featurePlans.search(for: text)
    }
  }

  private func resetError() {
    error = nil
  }
}
