//
//  CurrencyCode.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/11/24.
//

enum CurrencyCode: String, CaseIterable {
    case system = ""
    case usd = "USD"
    case eur = "EUR"
    case jpy = "JPY"

    var displayName: String {
        switch self {
        case .system:
            "System"
        default:
            rawValue
        }
    }
}
