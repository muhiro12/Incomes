//
//  CategoryComparisonSnapshot.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct CategoryComparisonSnapshot {
    @Guide(description: "The requested year.")
    var year: Int
    @Guide(description: "The requested month.")
    var month: Int
    @Guide(description: "The previous year used for comparison.")
    var previousYear: Int
    @Guide(description: "The previous month used for comparison.")
    var previousMonth: Int
    @Guide(description: "Up to eight category comparison rows sorted by the largest changes first.")
    var comparisons: [CategoryComparisonEntry]
}
