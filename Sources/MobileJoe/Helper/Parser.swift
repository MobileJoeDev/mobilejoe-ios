//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  Parser.swift
//
//  Created by Florian Mielke on 26.09.25.
//

import Foundation

class Parser {
  func parse<T: Decodable>(_ data: Data) throws -> T {
    try JSONDecoder.shared.decode(T.self, from: data)
  }
}
