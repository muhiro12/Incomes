//
//  CollectionExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Collection {
    var identified: [IdentifiedElement<Element>] {
        map { IdentifiedElement($0) }
    }
}
