import Foundation
import SwiftData

/// Domain operations for yearly item duplication selections and suggestions.
public enum YearlyItemDuplicationSelectionOperations {
    /// Returns the year component for `date` in `calendar`.
    public static func currentYear(
        date: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        calendar.component(.year, from: date)
    }

    /// Returns the default source year selection.
    public static func initialSourceYear(
        currentYear: Int = Self.currentYear()
    ) -> Int {
        currentYear - 1
    }

    /// Returns the default target year selection.
    public static func initialTargetYear(
        currentYear: Int = Self.currentYear()
    ) -> Int {
        currentYear
    }

    /// Returns source years extracted from persisted year tags, or `currentYear` when none exist.
    public static func availableSourceYears(
        context: ModelContext,
        currentYear: Int = Self.currentYear()
    ) throws -> [Int] {
        let yearTags = try context.fetch(.tags(.typeIs(.year), order: .reverse))
        return availableSourceYears(
            from: yearTags,
            currentYear: currentYear
        )
    }

    /// Returns source years extracted from `yearTags`, or `currentYear` when none exist.
    public static func availableSourceYears(
        from yearTags: [Tag],
        currentYear: Int = Self.currentYear()
    ) -> [Int] {
        let years = yearTags.compactMap { tag in
            YearlyItemDuplicationSupport.yearValue(from: tag)
        }
        if years.isEmpty {
            return [currentYear]
        }
        return Array(Set(years)).sorted(by: >)
    }

    /// Returns selectable target years centered around `currentYear`.
    public static func targetYears(
        currentYear: Int = Self.currentYear(),
        range: Int = 10
    ) -> [Int] {
        Array((currentYear - range)...(currentYear + range)).sorted(by: >)
    }

    /// Aligns source/target year selections for yearly duplication UI.
    public static func alignSelection(
        context: ModelContext,
        sourceYear: inout Int,
        targetYear: inout Int,
        preserveCurrentSelection: Bool,
        currentYear: Int = Self.currentYear(),
        targetYearRange: Int = 10,
        minimumGroupCount: Int = 3,
        options: YearlyItemDuplicationOptions = .init()
    ) throws {
        let yearTags = try context.fetch(.tags(.typeIs(.year), order: .reverse))
        alignSelection(
            context: context,
            yearTags: yearTags,
            sourceYear: &sourceYear,
            targetYear: &targetYear,
            preserveCurrentSelection: preserveCurrentSelection,
            currentYear: currentYear,
            targetYearRange: targetYearRange,
            minimumGroupCount: minimumGroupCount,
            options: options
        )
    }

    /// Aligns source/target year selections for yearly duplication UI.
    public static func alignSelection(
        context: ModelContext,
        yearTags: [Tag],
        sourceYear: inout Int,
        targetYear: inout Int,
        preserveCurrentSelection: Bool,
        currentYear: Int = Self.currentYear(),
        targetYearRange: Int = 10,
        minimumGroupCount: Int = 3,
        options: YearlyItemDuplicationOptions = .init()
    ) {
        let sourceYears = availableSourceYears(
            from: yearTags,
            currentYear: currentYear
        )
        let targetYears = targetYears(
            currentYear: currentYear,
            range: targetYearRange
        )
        let defaultSourceYear = sourceYears.first ?? currentYear
        let defaultTargetYear = targetYears.first ?? currentYear
        let suggestion = suggestion(
            context: context,
            yearTags: yearTags,
            targetYears: targetYears,
            minimumGroupCount: minimumGroupCount,
            options: options
        )
        let suggestedSourceYear = suggestion?.sourceYear ?? defaultSourceYear
        let suggestedTargetYear = suggestion?.targetYear ?? defaultTargetYear
        sourceYear = preserveCurrentSelection && sourceYears.contains(sourceYear)
            ? sourceYear
            : suggestedSourceYear
        targetYear = preserveCurrentSelection && targetYears.contains(targetYear)
            ? targetYear
            : suggestedTargetYear
    }

    /// Builds a suggested source and target year pair from available year tags.
    public static func suggestion(
        context: ModelContext,
        targetYears: [Int],
        minimumGroupCount: Int,
        options: YearlyItemDuplicationOptions = .init()
    ) throws -> YearlyItemDuplicationSuggestion? {
        let yearTags = try context.fetch(.tags(.typeIs(.year), order: .reverse))
        return suggestion(
            context: context,
            yearTags: yearTags,
            targetYears: targetYears,
            minimumGroupCount: minimumGroupCount,
            options: options
        )
    }

    /// Builds a suggested source and target year pair from available year tags.
    public static func suggestion(
        context: ModelContext,
        yearTags: [Tag],
        targetYears: [Int],
        minimumGroupCount: Int,
        options: YearlyItemDuplicationOptions = .init()
    ) -> YearlyItemDuplicationSuggestion? {
        let sourceYears = availableSourceYears(from: yearTags)
        return suggestion(
            context: context,
            sourceYears: sourceYears,
            targetYears: targetYears,
            minimumGroupCount: minimumGroupCount,
            options: options
        )
    }

    /// Builds a suggested source and target year pair from explicit year lists.
    public static func suggestion(
        context: ModelContext,
        sourceYears: [Int],
        targetYears: [Int],
        minimumGroupCount: Int,
        options: YearlyItemDuplicationOptions = .init()
    ) -> YearlyItemDuplicationSuggestion? {
        guard !sourceYears.isEmpty, !targetYears.isEmpty else {
            return nil
        }
        for year in sourceYears {
            let candidateTargetYear = year + 1
            guard targetYears.contains(candidateTargetYear) else {
                continue
            }
            if let plan = try? YearlyItemDuplicationPlanOperations.plan(
                context: context,
                sourceYear: year,
                targetYear: candidateTargetYear,
                options: options
            ), plan.groups.count >= minimumGroupCount {
                return .init(
                    sourceYear: year,
                    targetYear: candidateTargetYear,
                    plan: plan
                )
            }
        }
        let fallbackSourceYear = sourceYears.first ?? Self.currentYear()
        let fallbackTargetYear = targetYears.contains(fallbackSourceYear + 1)
            ? fallbackSourceYear + 1
            : targetYears.first ?? fallbackSourceYear + 1
        if let plan = try? YearlyItemDuplicationPlanOperations.plan(
            context: context,
            sourceYear: fallbackSourceYear,
            targetYear: fallbackTargetYear,
            options: options
        ) {
            return .init(
                sourceYear: fallbackSourceYear,
                targetYear: fallbackTargetYear,
                plan: plan
            )
        }
        return nil
    }
}
