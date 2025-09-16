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
}
