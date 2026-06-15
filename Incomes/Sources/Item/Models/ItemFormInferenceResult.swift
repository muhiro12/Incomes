//
//  ItemFormInferenceResult.swift
//  Incomes
//
//  Created by Codex on 2026/06/10.
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct ItemFormInferenceResult {
    @Guide(description: "yyyyMMdd date")
    var date: String
    var content: String
    @Guide(description: "Positive income amount, or 0")
    var income: Decimal
    @Guide(description: "Positive outgo amount, or 0")
    var outgo: Decimal
    var category: String
}
