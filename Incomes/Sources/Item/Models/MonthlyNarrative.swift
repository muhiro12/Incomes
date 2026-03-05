//
//  MonthlyNarrative.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import FoundationModels

@available(iOS 26.0, *)
@Generable
struct MonthlyNarrative {
    @Guide(description: "A single 3 to 6 sentence paragraph describing the month.")
    var summary: String
}
