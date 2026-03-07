import Foundation
import MHPlatform

enum IncomesMutationWorkflow {
    typealias NotificationScheduleRefresher = @MainActor @Sendable () async -> Void
    typealias ReviewRequester = @MainActor @Sendable () async -> MHReviewRequestOutcome

    @MainActor
    static func refreshNotificationSchedule(
        notificationService: NotificationService
    ) async {
        await notificationService.refresh()
        await notificationService.register()
    }

    @MainActor
    static func followUpHintAdapter(
        refreshNotificationSchedule: @escaping NotificationScheduleRefresher,
        reloadWidgets: @escaping @MainActor @Sendable () -> Void = {
            IncomesWidgetReloader.reloadAllWidgets()
        }
    ) -> MHMutationAdapter<Set<MutationOutcome.FollowUpHint>> {
        .init { followUpHints in
            var steps = [MHMutationStep]()

            if followUpHints.contains(.refreshNotificationSchedule) {
                steps.append(
                    .mainActor(name: "refreshNotificationSchedule") {
                        await refreshNotificationSchedule()
                    }
                )
            }

            if followUpHints.contains(.reloadWidgets) {
                steps.append(
                    .mainActor(
                        name: "reloadWidgets",
                        action: reloadWidgets
                    )
                )
            }

            return steps
        }
    }

    @MainActor
    static func itemFormAdapter(
        refreshNotificationSchedule: @escaping NotificationScheduleRefresher,
        requestReviewIfNeeded: @escaping ReviewRequester
    ) -> MHMutationAdapter<Set<MutationOutcome.FollowUpHint>> {
        followUpHintAdapter(
            refreshNotificationSchedule: refreshNotificationSchedule
        )
        .appending(
            [
                .mainActor(name: "successHaptic") {
                    Haptic.success.impact()
                },
                .mainActor(name: "scheduleReviewRequest") {
                    Task { @MainActor in
                        _ = await requestReviewIfNeeded()
                    }
                }
            ]
        )
    }

    @MainActor
    static func run<Value: Sendable>(
        name: String,
        operation: @escaping @MainActor @Sendable () throws -> Value,
        adapter: MHMutationAdapter<Value>
    ) async throws -> Value {
        try await MHMutationWorkflow.runThrowing(
            name: name,
            operation: operation,
            adapter: adapter
        )
    }

    @MainActor
    static func run<
        OperationValue,
        AdapterValue: Sendable,
        ResultValue: Sendable
    >(
        name: String,
        operation: @escaping @MainActor @Sendable () throws -> OperationValue,
        adapter: MHMutationAdapter<AdapterValue>,
        afterSuccess: @escaping @MainActor @Sendable (OperationValue) -> AdapterValue,
        returning: @escaping @MainActor @Sendable (OperationValue) -> ResultValue
    ) async throws -> ResultValue {
        try await MHMutationWorkflow.runThrowing(
            name: name,
            operation: operation,
            adapter: adapter,
            afterSuccess: afterSuccess,
            returning: returning
        )
    }
}
