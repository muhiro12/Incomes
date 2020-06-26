//
//  DecimalExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Decimal {
    var asNSDecimalNumber: NSDecimalNumber {
        NSDecimalNumber(decimal: self)
    }

    var asCurrency: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(for: self)
    }

    var asMinusCurrency: String? {
        return (-self).asCurrency
    }
}
