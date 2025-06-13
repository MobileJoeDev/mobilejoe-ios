//
//  File.swift
//  MobileJoe
//
//  Created by Florian Mielke on 08.05.25.
//

import SwiftUI

extension View {
  func errorAlert(error: Binding<Error?>) -> some View {
    let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
    return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
      Button {
        error.wrappedValue = nil
      } label: {
        Text("OK", bundle: .module)
      }
    } message: { error in
      Text(error.recoverySuggestion ?? "")
    }
  }
}

