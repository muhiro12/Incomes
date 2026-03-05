//
//  MonthlyTotalsSnapshot.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct MonthlyTotalsSnapshot {
    @Guide(description: "The requested year.")
    var year: Int
    @Guide(description: "The requested month.")
    var month: Int
    @Guide(description: "The app-selected currency code, such as USD or JPY.")
    var currencyCode: String
    @Guide(description: "Total income for the requested month.")
    var totalIncome: Decimal
    @Guide(description: "Total outgo for the requested month.")
    var totalOutgo: Decimal
    @Guide(description: "Net result for the requested month, equal to income minus outgo.")
    var netIncome: Decimal
}
