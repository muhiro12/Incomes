//
//  MonthlySummaryGenerationError.swift
//  IncomesLibrary
//
//  Created by Codex on 2026/03/05.
//

import Foundation

/// Failures that can stop monthly summary generation.
@available(iOS 26.0, *)
public enum MonthlySummaryGenerationError: LocalizedError, Equatable, Sendable, CaseIterable {
    /// The on-device language model is unavailable.
    case unavailableModel
    /// The current locale is unsupported by the on-device language model.
    case unsupportedLocale
    /// The requested month cannot be represented safely.
    case invalidYearMonth
    /// Summary generation failed after the input context was prepared.
    case generationFailed

    public var errorDescription: String? {
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
