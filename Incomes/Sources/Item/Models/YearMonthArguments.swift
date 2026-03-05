//
//  YearMonthArguments.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct YearMonthArguments {
    @Guide(description: "Four-digit year between 1 and 9999.")
    var year: Int
    @Guide(description: "Month number between 1 and 12.")
    var month: Int

    func resolvedDate() throws -> Date {
        guard (1...9_999).contains(year), // swiftlint:disable:this no_magic_numbers
              (1...12).contains(month) else { // swiftlint:disable:this no_magic_numbers
            throw MonthlySummaryGenerationError.invalidYearMonth
        }
        let value = String(format: "%04d%02d", year, month)
        guard let date = value.dateValueWithoutLocale(.yyyyMM) else {
            throw MonthlySummaryGenerationError.invalidYearMonth
        }
        return date
    }
}
