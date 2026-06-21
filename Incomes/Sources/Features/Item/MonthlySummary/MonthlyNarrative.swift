//
//  MonthlyNarrative.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import FoundationModels

@available(iOS 26.0, *)
@Generable(
    description: "A short user-visible monthly financial summary for one household finance month."
)
struct MonthlyNarrative: Sendable {
    @Guide(
        description: """
        One plain 3 to 6 sentence paragraph with only allowed numeric values. \
        Do not include prompt labels, schema labels, JSON, booleans, enum values, \
        camelCase identifiers, or implementation field names.
        """
    )
    var summary: String
}
