//
//  LocaleAmountConverter.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/22.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation

/// Converts amounts from a base USD value into a rough locale-sensitive scale.
public enum LocaleAmountConverter {
    /// Converts a base USD amount to an approximate local currency magnitude.
    /// - Parameters:
    ///   - baseUSD: Amount in USD used as a baseline.
    ///   - locale: Target locale (default: current).
    /// - Returns: Converted amount intended for demo/sample data.
    public static func localizedAmount(baseUSD: Decimal, locale: Locale = .current) -> Decimal {
        let currencyCode = CurrencyCode(rawValue: locale.currency?.identifier ?? "")
        let multiplier: Decimal

        switch currencyCode {
        case .usd,
             .eur:
            multiplier = 1
        case .cny:
            multiplier = 20
        case .jpy:
            multiplier = 100
        default:
            multiplier = 1
        }

        return baseUSD * multiplier
    }
}
