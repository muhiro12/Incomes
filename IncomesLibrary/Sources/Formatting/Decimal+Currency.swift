//  Decimal+Currency.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//

import Foundation
import MHPlatformCore

public extension Decimal {
    /// Formats the decimal using the currently selected currency code.
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = MHPreferenceStore().string(
            for: \.currencyCode,
            default: ""
        )
        guard let currency = formatter.string(for: self) else {
            assertionFailure()
            return ""
        }
        return currency
    }

    /// Formats the decimal as a negative currency string when the value is non-zero.
    var asMinusCurrency: String {
        guard self != .zero else {
            return asCurrency
        }
        guard !asCurrency.isEmpty else {
            return ""
        }
        return "-" + asCurrency
    }
}
