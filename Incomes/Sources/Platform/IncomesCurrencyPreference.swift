//
//  IncomesCurrencyPreference.swift
//  Incomes
//
//  Created by Codex on 2026/06/10.
//

import MHPlatform

enum IncomesCurrencyPreference {
    static func preferredCurrencyCode() -> String {
        MHPreferenceStore().string(
            for: \.currencyCode,
            default: ""
        )
    }
}
