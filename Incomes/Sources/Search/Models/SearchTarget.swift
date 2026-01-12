//
//  SearchTarget.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

enum SearchTarget: CaseIterable {
    case content
    case category
    case balance
    case income
    case outgo

    var value: LocalizedStringKey {
        switch self {
        case .content:
            "Content"
        case .category:
            "Category"
        case .balance:
            "Balance"
        case .income:
            "Income"
        case .outgo:
            "Outgo"
        }
    }

    var isForCurrency: Bool {
        switch self {
        case .content,
             .category:
            false
        case .balance,
             .income,
             .outgo:
            true
        }
    }

    func predicate(minimumText: String, maximumText: String) -> ItemPredicate? {
        guard isForCurrency else {
            return nil
        }

        let minimumValue = Decimal(string: minimumText) ?? -Decimal.greatestFiniteMagnitude
        let maximumValue = Decimal(string: maximumText) ?? Decimal.greatestFiniteMagnitude

        switch self {
        case .content,
             .category:
            return nil
        case .balance:
            return .balanceIsBetween(min: minimumValue, max: maximumValue)
        case .income:
            return .incomeIsBetween(min: minimumValue, max: maximumValue)
        case .outgo:
            return .outgoIsBetween(min: minimumValue, max: maximumValue)
        }
    }
}
