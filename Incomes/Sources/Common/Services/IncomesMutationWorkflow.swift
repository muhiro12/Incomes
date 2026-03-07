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
        let mutation = MHMutation.mainActor(name: name) {
            do {
                return try operation()
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                throw ExecutionError.operation(error.localizedDescription)
            }
        }

        let outcome = await MHMutationRunner.run(
            mutation: mutation,
            adapter: adapter
        )

        switch outcome {
        case .succeeded(let value, _, _):
            return value
        case .failed(let failure, _, _, _):
            switch failure {
            case .operation(let description):
                throw ExecutionError.operation(description)
            case let .step(name, description):
                throw ExecutionError.step(
                    name: name,
                    description: description
                )
            }
        case .cancelled:
            throw CancellationError()
        }
    }
}
