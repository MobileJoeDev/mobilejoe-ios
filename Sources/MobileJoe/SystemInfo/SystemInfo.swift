//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  SystemInfo.swift
//
//  Created by Florian Mielke on 27.06.25.
//

import Foundation

struct SystemInfo {
  static let frameworkVersion = "1.0.0"
  static let systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
  static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
  static let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
  
  static var deviceVersion: String {
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
