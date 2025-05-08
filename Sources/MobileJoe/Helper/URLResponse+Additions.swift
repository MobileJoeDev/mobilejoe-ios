//
//  Copyright Florian Mielke. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  URLResponse+Additions.swift
//
//  Created by Florian on 08.05.25.
//

import Foundation

extension URLResponse {
  var isOK: Bool {
    (self as? HTTPURLResponse)?.statusCode == 200
  }
}
