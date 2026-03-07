import Foundation
import MHPlatform

enum IncomesMutationWorkflow {
    typealias NotificationScheduleRefresher = @MainActor @Sendable () async -> Void
    typealias ReviewRequester = @MainActor @Sendable () async -> MHReviewRequestOutcome

    private enum ExecutionError: LocalizedError, Sendable, CustomStringConvertible {
        case operation(String)
        case step(name: String, description: String)

        var description: String {
            switch self {
            case .operation(let description):
                return description
            case let .step(name, description):
                if description.isEmpty {
                    return "Mutation step \(name) failed."
                }
                return description
            }
        }

        var errorDescription: String? {
            description
        }
    }

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
            adapter: adapter,
            mapFailure: executionError(from:),
            operationErrorDescription: operationErrorDescription
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
            returning: returning,
            mapFailure: executionError(from:),
            operationErrorDescription: operationErrorDescription
        )
    }

    nonisolated
    private static func executionError(
        from failure: MHMutationFailure
    ) -> ExecutionError {
        switch failure {
        case .operation(let description):
            return .operation(description)
        case let .step(name, description):
            return .step(
                name: name,
                description: description
            )
        }
    }

    nonisolated
    private static func operationErrorDescription(
        _ error: any Error
    ) -> String {
        error.localizedDescription
    }
}
