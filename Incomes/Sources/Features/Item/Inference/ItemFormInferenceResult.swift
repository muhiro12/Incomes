//
//  ItemFormInferenceResult.swift
//  Incomes
//
//  Created by Codex on 2026/06/10.
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable(description: "A single household finance item inferred from user text.")
struct ItemFormInferenceResult: Sendable {
    @Guide(description: "The item date as yyyyMMdd, or empty for an invalid or ambiguous day.")
    var date: String
    @Guide(description: "A short item description in the requested language.")
    var content: String
    @Guide(description: "True only when no amount is given or the amount is undecided. False for an explicit zero.")
    var hasUnspecifiedAmount: Bool
    @Guide(description: "Income amount, or 0 for an expense or an unspecified amount.")
    var income: Decimal
    @Guide(description: "Outgo amount, or 0 for income or an unspecified amount.")
    var outgo: Decimal
    @Guide(description: "A concise category name in the requested language.")
    var category: String
}
