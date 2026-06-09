import Foundation
import SwiftData

/// Domain operations for yearly item duplication selections and suggestions.
public enum YearlyItemDuplicationSelectionOperations {
    /// Returns source years extracted from persisted year tags, or `currentYear` when none exist.
    public static func availableSourceYears(
        context: ModelContext,
        currentYear: Int = Calendar.current.component(.year, from: .now)
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
        currentYear: Int = Calendar.current.component(.year, from: .now)
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
        currentYear: Int = Calendar.current.component(.year, from: .now),
        range: Int = 10
    ) -> [Int] {
        Array((currentYear - range)...(currentYear + range)).sorted(by: >)
    }

    /// Resolves source/target year selections for yearly duplication UI.
    public static func selectionState(
        context: ModelContext,
        currentSourceYear: Int,
        currentTargetYear: Int,
        preserveCurrentSelection: Bool,
        currentYear: Int = Calendar.current.component(.year, from: .now),
        targetYearRange: Int = 10,
        minimumGroupCount: Int = 3,
        options: YearlyItemDuplicationOptions = .init()
    ) throws -> YearlyItemDuplicationSelectionState {
        let yearTags = try context.fetch(.tags(.typeIs(.year), order: .reverse))
        return selectionState(
            context: context,
            yearTags: yearTags,
            currentSourceYear: currentSourceYear,
            currentTargetYear: currentTargetYear,
            preserveCurrentSelection: preserveCurrentSelection,
            currentYear: currentYear,
            targetYearRange: targetYearRange,
            minimumGroupCount: minimumGroupCount,
            options: options
        )
    }

    /// Resolves source/target year selections for yearly duplication UI.
    public static func selectionState(
        context: ModelContext,
        yearTags: [Tag],
        currentSourceYear: Int,
        currentTargetYear: Int,
        preserveCurrentSelection: Bool,
        currentYear: Int = Calendar.current.component(.year, from: .now),
        targetYearRange: Int = 10,
        minimumGroupCount: Int = 3,
        options: YearlyItemDuplicationOptions = .init()
    ) -> YearlyItemDuplicationSelectionState {
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
        let sourceYear = preserveCurrentSelection && sourceYears.contains(currentSourceYear)
            ? currentSourceYear
            : suggestedSourceYear
        let targetYear = preserveCurrentSelection && targetYears.contains(currentTargetYear)
            ? currentTargetYear
            : suggestedTargetYear
        return .init(
            sourceYear: sourceYear,
            targetYear: targetYear
        )
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
        guard sourceYears.isNotEmpty, targetYears.isNotEmpty else {
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
        let fallbackSourceYear = sourceYears.first ?? Calendar.current.component(.year, from: .now)
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
