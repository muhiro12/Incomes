//
//  MonthlySummaryGenerationError.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import Foundation

@available(iOS 26.0, *)
enum MonthlySummaryGenerationError: LocalizedError {
    case unavailableModel
    case unsupportedLocale
    case invalidYearMonth
    case generationFailed

    var errorDescription: String? {
        switch self {
        case .unavailableModel:
            return String(localized: "On-device monthly summaries are currently unavailable.")
        case .unsupportedLocale:
            return String(localized: "On-device monthly summaries are unavailable in the current language.")
        case .invalidYearMonth:
            return String(localized: "Invalid month requested for summary generation.")
        case .generationFailed:
            return String(localized: "Unable to generate the monthly summary.")
        }
    }
}
