//
//  LocaleAmountConverter.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/22.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation

public nonisolated enum LocaleAmountConverter {
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
