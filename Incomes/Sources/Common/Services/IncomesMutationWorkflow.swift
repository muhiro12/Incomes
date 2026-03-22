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
}
