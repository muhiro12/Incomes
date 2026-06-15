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
    @Guide(description: "The item date formatted as yyyyMMdd.")
    var date: String
    @Guide(description: "A short item description in the requested language.")
    var content: String
    @Guide(description: "Positive income amount, or 0 when this item is not income.")
    var income: Decimal
    @Guide(description: "Positive outgo amount, or 0 when this item is not outgo.")
    var outgo: Decimal
    @Guide(description: "A concise category name in the requested language.")
    var category: String
}
