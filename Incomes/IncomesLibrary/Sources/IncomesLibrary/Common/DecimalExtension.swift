//
//  DecimalExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

public nonisolated extension Decimal {
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = AppStorage(.currencyCode).wrappedValue
        guard let currency = formatter.string(for: self) else {
            assertionFailure()
            return .empty
        }
        return currency
    }

    var asMinusCurrency: String {
        guard isNotZero else {
            return asCurrency
        }
        guard asCurrency.isNotEmpty else {
            return .empty
        }
        return "-" + asCurrency
    }

    var isPlus: Bool {
        self > .zero
    }

    var isMinus: Bool {
        self < .zero
    }
}
