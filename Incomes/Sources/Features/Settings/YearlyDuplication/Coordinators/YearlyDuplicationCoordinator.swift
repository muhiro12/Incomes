import Foundation
import MHPlatform
import SwiftData

enum YearlyDuplicationCoordinator {
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
        let metadata = applyMetadata(
            group: group,
            entries: entries,
            plan: plan
        )
        guard !entries.isEmpty else {
            logSkippedApply(metadata: metadata, logger: logger)
            return nil
        }
        logger.notice(
            "yearly_duplication.apply_requested",
            metadata: metadata
        )

        do {
            let result = try await runApplyWorkflow(
                group: group,
                plan: plan,
                context: context,
                refreshNotificationSchedule: refreshNotificationSchedule,
                logger: logger
            )
            logCompletedApply(
                result: result,
                metadata: metadata,
                logger: logger
            )
            return result
        } catch {
            logger.error(
                "yearly_duplication.apply_failed",
                metadata: failureMetadata(metadata, error: error)
            )
            throw error
        }
    }
}

private extension YearlyDuplicationCoordinator {
    static func applyMetadata(
        group: YearlyItemDuplicationGroup,
        entries: [YearlyItemDuplicationEntry],
        plan: YearlyItemDuplicationPlan
    ) -> [String: String] {
        IncomesLogging.metadata(
            ("group_count", "1"),
            ("item_count", IncomesLogging.count(entries.count)),
            ("skipped_count", IncomesLogging.count(plan.skippedDuplicateCount)),
            ("category_present", IncomesLogging.presence(group.category))
        )
    }

    static func logSkippedApply(
        metadata: [String: String],
        logger: MHLogger
    ) {
        logger.info(
            "yearly_duplication.apply_skipped",
            metadata: metadata
        )
    }

    static func runApplyWorkflow(
        group: YearlyItemDuplicationGroup,
        plan: YearlyItemDuplicationPlan,
        context: ModelContext,
        refreshNotificationSchedule: @escaping IncomesMutationWorkflow.NotificationScheduleRefresher,
        logger: MHLogger
    ) async throws -> YearlyItemDuplicationResult {
        let adapter = IncomesMutationWorkflow.followUpHintAdapter(
            refreshNotificationSchedule: refreshNotificationSchedule
        )
        return try await MHMutationWorkflow.runThrowing(
            name: "duplicateYearlyItems",
            operation: {
                guard let result = try YearlyItemDuplicationApplyOperations.applyWithOutcome(
                    groupID: group.id,
                    in: plan,
                    context: context
                ) else {
                    throw YearlyItemDuplicationError.missingGroup(group.id)
                }
                return result
            },
            adapter: adapter,
            projection: .valueAndFollowUp(
                value: \.value,
                followUp: \.outcome.followUpHints
            ),
            onEvent: MHMutationWorkflowLogger(logger: logger).onEvent()
        )
    }

    static func logCompletedApply(
        result: YearlyItemDuplicationResult,
        metadata: [String: String],
        logger: MHLogger
    ) {
        logger.notice(
            "yearly_duplication.apply_completed",
            metadata: completedMetadata(
                metadata,
                result: result
            )
        )
    }

    static func completedMetadata(
        _ metadata: [String: String],
        result: YearlyItemDuplicationResult
    ) -> [String: String] {
        metadata.merging(
            IncomesLogging.metadata(
                ("created_count", IncomesLogging.count(result.createdCount))
            )
        ) { current, _ in
            current
        }
    }

    static func failureMetadata(
        _ metadata: [String: String],
        error: any Error
    ) -> [String: String] {
        metadata.merging(IncomesLogging.errorMetadata(error)) { current, _ in
            current
        }
    }
}
