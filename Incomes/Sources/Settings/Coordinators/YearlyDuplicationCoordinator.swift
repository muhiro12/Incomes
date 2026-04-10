import Foundation
import MHPlatform
import SwiftData

enum YearlyDuplicationCoordinator { // swiftlint:disable:this type_body_length
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
        targetYear: Int,
        logger: MHLogger
    ) throws -> YearlyItemDuplicationPlan {
        let metadata = IncomesLogging.metadata(
            ("source_year", String(sourceYear)),
            ("target_year", String(targetYear))
        )
        logger.notice(
            "yearly_duplication.preview_requested",
            metadata: metadata
        )
        do {
            let plan = try YearlyItemDuplicator.plan(
                context: context,
                sourceYear: sourceYear,
                targetYear: targetYear
            )
            logger.notice(
                "yearly_duplication.preview_completed",
                metadata: metadata.merging(
                    IncomesLogging.metadata(
                        ("group_count", IncomesLogging.count(plan.groups.count)),
                        ("item_count", IncomesLogging.count(plan.entries.count)),
                        ("skipped_count", IncomesLogging.count(plan.skippedDuplicateCount))
                    )
                ) { current, _ in
                    current
                }
            )
            return plan
        } catch {
            logger.error(
                "yearly_duplication.preview_failed",
                metadata: metadata.merging(IncomesLogging.errorMetadata(error)) { current, _ in
                    current
                }
            )
            throw error
        }
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

    // swiftlint:disable function_body_length
    static func apply(
        group: YearlyItemDuplicationGroup,
        in plan: YearlyItemDuplicationPlan,
        context: ModelContext,
        refreshNotificationSchedule: @escaping IncomesMutationWorkflow.NotificationScheduleRefresher,
        logger: MHLogger
    ) async throws -> YearlyItemDuplicationResult? {
        let entries = entries(
            for: group,
            in: plan
        )
        let metadata = IncomesLogging.metadata(
            ("group_count", "1"),
            ("item_count", IncomesLogging.count(entries.count)),
            ("skipped_count", IncomesLogging.count(plan.skippedDuplicateCount)),
            ("category_present", IncomesLogging.presence(group.category))
        )
        guard entries.isNotEmpty else {
            logger.info(
                "yearly_duplication.apply_skipped",
                metadata: metadata
            )
            return nil
        }
        logger.notice(
            "yearly_duplication.apply_requested",
            metadata: metadata
        )

        let adapter = IncomesMutationWorkflow
            .followUpHintAdapter(
                refreshNotificationSchedule: refreshNotificationSchedule
            )

        do {
            let result = try await MHMutationWorkflow.runThrowing(
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
                projection: .keyPaths(
                    adapterValue: \.outcome.followUpHints,
                    resultValue: \.value
                )
            )
            logger.notice(
                "yearly_duplication.apply_completed",
                metadata: metadata.merging(
                    IncomesLogging.metadata(
                        ("created_count", IncomesLogging.count(result.createdCount))
                    )
                ) { current, _ in
                    current
                }
            )
            return result
        } catch {
            let failureMetadata = metadata.merging(
                IncomesLogging.errorMetadata(error)
            ) { current, _ in
                current
            }
            logger.error(
                "yearly_duplication.apply_failed",
                metadata: failureMetadata
            )
            throw error
        }
    }
    // swiftlint:enable function_body_length

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
