//
//  OptionalExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Optional {
    var string: String {
        self as? String ?? ""
    }

    var decimal: Decimal {
        self as? Decimal ?? .zero
    }
}
