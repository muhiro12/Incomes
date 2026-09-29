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
        refreshNotificationSchedule: @escaping IncomesMutationWorkflow.NotificationScheduleRefresher,
        logger: MHLogger
    ) async throws -> ItemImportResult {
        let metadata = IncomesLogging.metadata(
            ("policy", policyName(request.policy)),
            ("item_count", IncomesLogging.count(request.contents.items.count))
        )
        logger.notice("data_import.apply_requested", metadata: metadata)
        do {
            let adapter = IncomesMutationWorkflow.followUpHintAdapter(
                refreshNotificationSchedule: refreshNotificationSchedule
            )
            let result = try await MHMutationWorkflow.runThrowing(
                name: "importItems",
                operation: {
                    let mutation = try ItemImportOperations.applyWithOutcome(
                        contents: request.contents,
                        reviewed: request.difference,
                        policy: request.policy,
                        context: context
                    )
                    // Save before follow-ups so widgets, Watch, and notifications read the imported data.
                    try context.save()
                    return mutation
                },
                adapter: adapter,
                projection: .valueAndFollowUp(
                    value: \.value,
                    followUp: \.outcome.followUpHints
                ),
                onEvent: MHMutationWorkflowLogger(logger: logger).onEvent()
            )
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
            // Discard any partial insertions or deletions that were not saved.
            context.rollback()
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
    static func policyName(_ policy: ItemImportPolicy) -> String {
        switch policy {
        case .replace:
            "replace"
        case .merge:
            "merge"
        }
    }
}
