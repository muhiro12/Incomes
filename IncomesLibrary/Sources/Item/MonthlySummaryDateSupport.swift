//
//  MonthlySummaryDateSupport.swift
//  IncomesLibrary
//
//  Shared date support for monthly summaries.
//

import Foundation

/// Provides shared date calculations for monthly summaries.
public enum MonthlySummaryDateSupport {
    /// Returns a date in the month before `date` using the UTC calendar.
    public static func previousMonthDate(from date: Date) -> Date {
        Calendar.utc.date(byAdding: .month, value: -1, to: date) ?? date
    }
}
