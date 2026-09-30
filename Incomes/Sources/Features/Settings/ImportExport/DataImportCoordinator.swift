import Foundation
import MHPlatform
import SwiftData

/// Applies a reviewed import through the shared mutation workflow and saves it once.
enum DataImportCoordinator {
    /// A file, the difference the person reviewed, and the chosen policy.
    struct Request {
        let contents: IncomesFileContents
        let difference: ItemImportDifference
        let policy: ItemImportPolicy
    }

    static func apply(
        _ request: Request,
        context: ModelContext,
        didSave: @MainActor () -> Void,
        refreshNotificationSchedule: @escaping IncomesMutationWorkflow.NotificationScheduleRefresher,
        logger: MHLogger
    ) async throws -> ItemImportResult {
        let metadata = IncomesLogging.metadata(
            ("policy", policyName(request.policy)),
            ("item_count", IncomesLogging.count(request.contents.items.count))
        )
        logger.notice("data_import.apply_requested", metadata: metadata)
        do {
            // Keep typed validation errors intact so the screen can refresh a stale review.
            let mutation = try ItemImportOperations.applyAndSaveWithOutcome(
                contents: request.contents,
                reviewed: request.difference,
                policy: request.policy,
                context: context
            )
            didSave()
            await performFollowUps(
                for: mutation,
                refreshNotificationSchedule: refreshNotificationSchedule,
                logger: logger
            )
            let result = mutation.value
            logger.notice(
                "data_import.apply_completed",
                metadata: metadata.merging(
                    IncomesLogging.metadata(
                        ("added_count", IncomesLogging.count(result.addedCount)),
                        ("removed_count", IncomesLogging.count(result.removedCount))
                    )
                ) { current, _ in
                    current
                }
            )
            return result
        } catch {
            logger.error(
                "data_import.apply_failed",
                metadata: metadata.merging(IncomesLogging.errorMetadata(error)) { current, _ in
                    current
                }
            )
            throw error
        }
    }
}

private extension DataImportCoordinator {
    static func performFollowUps(
        for mutation: MutationResult<ItemImportResult>,
        refreshNotificationSchedule: @escaping IncomesMutationWorkflow.NotificationScheduleRefresher,
        logger: MHLogger
    ) async {
        let adapter = IncomesMutationWorkflow.followUpHintAdapter(
            refreshNotificationSchedule: refreshNotificationSchedule
        )
        do {
            _ = try await MHMutationWorkflow.runThrowing(
                name: "importItems",
                operation: {
                    mutation
                },
                adapter: adapter,
                projection: .valueAndFollowUp(
                    value: \.value,
                    followUp: \.outcome.followUpHints
                ),
                onEvent: MHMutationWorkflowLogger(logger: logger).onEvent()
            )
        } catch {
            // The import is already saved. A follow-up failure must not invite a duplicate retry.
            logger.warning("data_import.follow_up_failed", metadata: IncomesLogging.errorMetadata(error))
        }
    }

    static func policyName(_ policy: ItemImportPolicy) -> String {
        switch policy {
        case .replace:
            "replace"
        case .merge:
            "merge"
        }
    }
}
