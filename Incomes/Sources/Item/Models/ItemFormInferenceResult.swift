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
    @Guide(description: "Date formatted as yyyyMMdd")
    var date: String
    @Guide(description: "Item content")
    var content: String
    @Guide(description: "Income amount")
    var income: Decimal
    @Guide(description: "Outgo amount")
    var outgo: Decimal
    @Guide(description: "Category name")
    var category: String
}
