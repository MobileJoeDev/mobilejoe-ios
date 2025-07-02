//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequest+Sorting.swift
//
//  Created by Florian Mielke on 02.07.25.
//

import Foundation

extension FeatureRequest {
  public enum Sorting: CaseIterable, Identifiable {
    case byNewest
    case byScore
    
    public var id: Self { self }
  }
}
