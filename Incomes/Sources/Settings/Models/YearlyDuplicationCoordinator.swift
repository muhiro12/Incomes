import Foundation
import MHPlatform
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
        let state = YearlyItemDuplicator.selectionState(
            context: context,
            yearTags: yearTags,
            currentSourceYear: currentSourceYear,
            currentTargetYear: currentTargetYear,
            preserveCurrentSelection: preserveCurrentSelection,
            currentYear: currentYear,
            minimumGroupCount: 3 // swiftlint:disable:this no_magic_numbers
        )
        return .init(
            sourceYear: state.sourceYear,
            targetYear: state.targetYear
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
        guard let draft = YearlyItemDuplicator.draft(
            for: group.id,
            in: plan
        ) else {
            return nil
        }
        return .init(
            groupID: draft.groupID,
            date: draft.date,
            content: draft.content,
            incomeText: draft.incomeText,
            outgoText: draft.outgoText,
            category: draft.category,
            priorityText: draft.priorityText,
            repeatMonthSelections: draft.repeatMonthSelections
        )
    }

    static func apply(
        group: YearlyItemDuplicationGroup,
        in plan: YearlyItemDuplicationPlan,
        context: ModelContext,
        refreshNotificationSchedule: @escaping IncomesMutationWorkflow.NotificationScheduleRefresher
    ) async throws -> YearlyItemDuplicationResult? {
        let entries = entries(
            for: group,
            in: plan
        )
        guard entries.isNotEmpty else {
            return nil
        }

        let adapter = IncomesMutationWorkflow
            .followUpHintAdapter(
                refreshNotificationSchedule: refreshNotificationSchedule
            )

        return try await IncomesMutationWorkflow.run(
            name: "duplicateYearlyItems",
            operation: {
                try YearlyItemDuplicator.applyWithOutcome(
                    plan: .init(
                        groups: [group],
                        entries: entries,
                        skippedDuplicateCount: 0
                    ),
                    context: context
                )
            },
            adapter: adapter,
            afterSuccess: { result in
                result.outcome.followUpHints
            },
            returning: { result in
                result.value
            }
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
                minimumGroupCount: 3 // swiftlint:disable:this no_magic_numbers
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
        randomValue: Int = Int.random(in: 0..<3) // swiftlint:disable:this no_magic_numbers
    ) -> Bool {
        let month = Calendar.current.component(.month, from: date)
        guard [11, 12, 1, 2].contains(month) else { // swiftlint:disable:this no_magic_numbers
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
        var source = value
        var rounded = Decimal.zero
        NSDecimalRound(&rounded, &source, 0, .down)
        return rounded.description
    }
}

private extension YearlyDuplicationCoordinator {
    struct MonthDay: Hashable {
        let month: Int
        let day: Int
    }
}
