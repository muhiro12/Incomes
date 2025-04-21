//
//  CurrencyCode.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/11/24.
//

import SwiftUI

enum CurrencyCode: String, CaseIterable {
    case system = ""
    case usd = "USD"
    case eur = "EUR"
    case cny = "CNY"
    case jpy = "JPY"

    var displayName: LocalizedStringKey {
        switch self {
        case .system:
            "System"
        default:
            .init(rawValue)
        }
    }
}
