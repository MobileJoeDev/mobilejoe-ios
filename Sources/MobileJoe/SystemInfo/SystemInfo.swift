// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

struct SystemInfo {
  static let frameworkVersion = "1.0.1"
  static let osName = "iOS"
  static let osVersion = ProcessInfo.processInfo.operatingSystemVersion.apiDescription
  static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
  static let appBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
  static let preferredLanguages = preferredLanguagesHeader(from: Locale.preferredLanguages)

  static func preferredLanguagesHeader(from languages: [String]) -> String? {
    languages.isEmpty ? nil : languages.joined(separator: ",")
  }

  static var deviceModel: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    return identifier
  }
}

extension OperatingSystemVersion {
  fileprivate var apiDescription: String {
    "\(majorVersion).\(minorVersion).\(patchVersion)"
  }
}
