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
    case balance
    case income
    case outgo

    var value: LocalizedStringKey {
        switch self {
        case .content:
            "Content"
        case .balance:
            "Balance"
        case .income:
            "Income"
        case .outgo:
            "Outgo"
        }
    }
}
