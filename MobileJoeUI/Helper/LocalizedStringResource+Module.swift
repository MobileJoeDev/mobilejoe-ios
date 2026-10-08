// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

extension LocalizedStringResource.BundleDescription {
  /// `MobileJoeUI`'s own resource bundle, holding `Localizable.xcstrings`.
  static var module: Self { .atURL(Bundle.module.bundleURL) }
}
