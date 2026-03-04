import Foundation
import SwiftData

enum YearlyDuplicationCoordinator {
    struct SelectionState {
        let sourceYear: Int
        let targetYear: Int
    }

    struct PromoState {
        let proposal: YearlyItemDuplicationGroup
        let sourceYear: Int
        let targetYear: Int
    }

    static func sourceYears(
        from yearTags: [Tag],
        currentYear: Int = Calendar.current.component(.year, from: .now)
    ) -> [Int] {
        YearlyItemDuplicator.availableSourceYears(
            from: yearTags,
            currentYear: currentYear
        )
    }

    static func targetYears(
        currentYear: Int = Calendar.current.component(.year, from: .now),
        range: Int = 10
    ) -> [Int] {
        YearlyItemDuplicator.targetYears(
            currentYear: currentYear,
            range: range
        )
    }

    static func selectionState(
        context: ModelContext,
        yearTags: [Tag],
        currentSourceYear: Int,
        currentTargetYear: Int,
        preserveCurrentSelection: Bool,
        currentYear: Int = Calendar.current.component(.year, from: .now)
    ) -> SelectionState {
        let sourceYears = sourceYears(
            from: yearTags,
            currentYear: currentYear
        )
        let targetYears = targetYears(currentYear: currentYear)
        let defaultSourceYear = sourceYears.first ?? currentYear
        let defaultTargetYear = targetYears.first ?? currentYear
        let suggestion = YearlyItemDuplicator.suggestion(
            context: context,
            yearTags: yearTags,
            targetYears: targetYears,
            minimumGroupCount: 3
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

    static func previewPlan(
        context: ModelContext,
        sourceYear: Int,
        targetYear: Int
    ) throws -> YearlyItemDuplicationPlan {
        try YearlyItemDuplicator.plan(
            context: context,
            sourceYear: sourceYear,
            targetYear: targetYear
        )
    }

    static func entries(
        for group: YearlyItemDuplicationGroup,
        in plan: YearlyItemDuplicationPlan
    ) -> [YearlyItemDuplicationEntry] {
        plan.entries.filter { entry in
            entry.groupID == group.id
        }
    }

    static func createDraft(
        for group: YearlyItemDuplicationGroup,
        in plan: YearlyItemDuplicationPlan
    ) -> ItemFormDraft? {
        let entries = entries(
            for: group,
            in: plan
        )
        guard let baseDate = entries.map(\.targetDate).sorted().first else {
            return nil
        }
        return .init(
            groupID: group.id,
            date: baseDate,
            content: group.content,
            incomeText: decimalString(from: group.averageIncome),
            outgoText: decimalString(from: group.averageOutgo),
            category: group.category,
            priorityText: .empty,
            repeatMonthSelections: repeatMonthSelections(from: entries)
        )
    }

    static func apply(
        group: YearlyItemDuplicationGroup,
        in plan: YearlyItemDuplicationPlan,
        context: ModelContext
    ) throws -> YearlyItemDuplicationResult? {
        let entries = entries(
            for: group,
            in: plan
        )
        guard entries.isNotEmpty else {
            return nil
        }
        return try YearlyItemDuplicator.apply(
            plan: singleGroupPlan(
                group: group,
                entries: entries
            ),
            context: context
        )
    }

    static func promoState(
        context: ModelContext,
        yearTags: [Tag],
        currentYear: Int = Calendar.current.component(.year, from: .now)
    ) -> PromoState? {
        let targetYears = targetYears(currentYear: currentYear)
        guard
            let suggestion = YearlyItemDuplicator.suggestion(
                context: context,
                yearTags: yearTags,
                targetYears: targetYears,
                minimumGroupCount: 3
            ),
            let proposal = suggestion.plan.groups.first
        else {
            return nil
        }
        return .init(
            proposal: proposal,
            sourceYear: suggestion.sourceYear,
            targetYear: suggestion.targetYear
        )
    }

    static func shouldShowPromo(
        date: Date = .now,
        randomValue: Int = Int.random(in: 0..<3)
    ) -> Bool {
        let month = Calendar.current.component(.month, from: date)
        guard [11, 12, 1, 2].contains(month) else {
            return false
        }
        return randomValue == 0
    }

    static func monthDayListText(
        for group: YearlyItemDuplicationGroup
    ) -> String {
        let calendar = Calendar.current
        let monthDays = group.targetDates.map { date in
            MonthDay(
                month: calendar.component(.month, from: date),
                day: calendar.component(.day, from: date)
            )
        }
        let sortedMonthDays = Array(Set(monthDays)).sorted { left, right in
            if left.month != right.month {
                return left.month < right.month
            }
            return left.day < right.day
        }
        return sortedMonthDays
            .map { monthDay in
                "\(monthDay.month)/\(monthDay.day)"
            }
            .joined(separator: ", ")
    }

    static func decimalString(from value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let rounded = number.rounding(
            accordingToBehavior: NSDecimalNumberHandler(
                roundingMode: .down,
                scale: 0,
                raiseOnExactness: false,
                raiseOnOverflow: false,
                raiseOnUnderflow: false,
                raiseOnDivideByZero: false
            )
        )
        return rounded.stringValue
    }
}

private extension YearlyDuplicationCoordinator {
    struct MonthDay: Hashable {
        let month: Int
        let day: Int
    }

    static func singleGroupPlan(
        group: YearlyItemDuplicationGroup,
        entries: [YearlyItemDuplicationEntry]
    ) -> YearlyItemDuplicationPlan {
        .init(
            groups: [group],
            entries: entries,
            skippedDuplicateCount: 0
        )
    }

    static func repeatMonthSelections(
        from entries: [YearlyItemDuplicationEntry]
    ) -> Set<RepeatMonthSelection> {
        let calendar = Calendar.current
        return Set(entries.map { entry in
            .init(
                year: calendar.component(.year, from: entry.targetDate),
                month: calendar.component(.month, from: entry.targetDate)
            )
        })
    }
}
