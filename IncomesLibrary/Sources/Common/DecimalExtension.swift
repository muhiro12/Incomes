// // swiftlint:disable:this file_name
//  DecimalExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//

import SwiftUI

public extension Decimal {
    /// Formats the decimal using the currently selected currency code.
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

    /// Formats the decimal as a negative currency string when the value is non-zero.
    var asMinusCurrency: String {
        guard isNotZero else {
            return asCurrency
        }
        guard asCurrency.isNotEmpty else {
            return .empty
        }
        return "-" + asCurrency
    }
}
