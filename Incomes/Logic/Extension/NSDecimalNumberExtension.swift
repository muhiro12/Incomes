//
//  NSDecimalNumberExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension NSDecimalNumber {
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        guard let currency = formatter.string(for: self) else {
            assertionFailure()
            return .empty
        }
        return currency
    }

    var asMinusCurrency: String {
        guard asCurrency.isNotEmpty else {
            return .empty
        }
        return "-" + asCurrency
    }
}
