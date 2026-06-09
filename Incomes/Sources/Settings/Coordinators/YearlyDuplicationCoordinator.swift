import Foundation
import MHPlatform
import SwiftData

enum YearlyDuplicationCoordinator {
    struct PromoState {
        let proposal: YearlyItemDuplicationGroup
        let sourceYear: Int
        let targetYear: Int
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
            let plan = try YearlyItemDuplicationPlanOperations.plan(
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

    static func createDraft(
        for group: YearlyItemDuplicationGroup,
        in plan: YearlyItemDuplicationPlan
    ) -> ItemFormDraft? {
        YearlyItemDuplicationPlanOperations.draft(
            for: group.id,
            in: plan
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
        let entries = YearlyItemDuplicationPlanOperations.entries(
            for: group.id,
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
                    try YearlyItemDuplicationApplyOperations.applyWithOutcome(
                        plan: .init(
                            groups: [group],
                            entries: entries,
                            skippedDuplicateCount: 0
                        ),
                        context: context
                    )
                },
                adapter: adapter,
                projection: .valueAndFollowUp(
                    value: \.value,
                    followUp: \.outcome.followUpHints
                ),
                onEvent: MHMutationWorkflowLogger(logger: logger).onEvent()
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
        currentYear: Int = YearlyItemDuplicationSelectionOperations.currentYear()
    ) -> PromoState? {
        let targetYears = YearlyItemDuplicationSelectionOperations.targetYears(
            currentYear: currentYear
        )
        guard
            let suggestion = try? YearlyItemDuplicationSelectionOperations.suggestion(
                context: context,
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
}
