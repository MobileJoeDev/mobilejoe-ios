//
//  File.swift
//  MobileJoe
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
