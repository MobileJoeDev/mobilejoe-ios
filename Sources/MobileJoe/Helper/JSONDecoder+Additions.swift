//
//  Copyright Florian Mielke. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  JSONDecoder+Additions.swift
//
//  Created by Florian on 20.03.25.
//

import Foundation

extension JSONDecoder {
  static let shared: JSONDecoder = {
    let d = JSONDecoder()
    d.dateDecodingStrategy = .formatted(.apiDateFormatter)
    return d
  }()
}
