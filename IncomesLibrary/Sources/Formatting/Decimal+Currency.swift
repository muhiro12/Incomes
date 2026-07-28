//  Decimal+Currency.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//

import Foundation
import MHPlatformCore

enum DecimalCurrencyFormatter {
    static func currencyText(
        for value: Decimal,
        currencyCode: String,
        locale: Locale
    ) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(for: value)
    }
}

public extension Decimal {
    /// Formats the decimal using the currently selected currency code.
    var asCurrency: String {
        currencyText()
    }

    /// Formats the decimal as a negative currency string when the value is non-zero.
    var asMinusCurrency: String {
        minusCurrencyText()
    }

    /// Formats the decimal using the selected currency code and `locale`.
    func currencyText(locale: Locale = .current) -> String {
        let currencyCode = MHPreferenceStore().string(
            for: \.currencyCode,
            default: ""
        )
        guard let currency = DecimalCurrencyFormatter.currencyText(
            for: self,
            currencyCode: currencyCode,
            locale: locale
        ) else {
            assertionFailure()
            return ""
        }
        return currency
    }

    /// Formats a non-zero decimal as negative currency using `locale`.
    func minusCurrencyText(locale: Locale = .current) -> String {
        let currency = currencyText(locale: locale)
        guard self != .zero else {
            return currency
        }
        guard !currency.isEmpty else {
            return ""
        }
        return "-" + currency
    }
}
