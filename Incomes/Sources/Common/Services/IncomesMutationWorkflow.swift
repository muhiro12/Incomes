import Foundation
import MHPlatform

enum IncomesMutationWorkflow {
    typealias NotificationScheduleRefresher = @MainActor @Sendable () async -> Void

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
