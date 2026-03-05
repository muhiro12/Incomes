//
//  CategoryComparisonEntry.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct CategoryComparisonEntry {
    @Guide(description: "The category display name.")
    var category: String
    @Guide(description: "Current-month income total for this category.")
    var currentIncome: Decimal
    @Guide(description: "Previous-month income total for this category.")
    var previousIncome: Decimal
    @Guide(description: "Current income minus previous income for this category.")
    var incomeDelta: Decimal
    @Guide(description: "Current-month outgo total for this category.")
    var currentOutgo: Decimal
    @Guide(description: "Previous-month outgo total for this category.")
    var previousOutgo: Decimal
    @Guide(description: "Current outgo minus previous outgo for this category.")
    var outgoDelta: Decimal
}
