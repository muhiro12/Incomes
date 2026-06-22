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
        .build { followUpHints in
            if followUpHints.contains(.refreshNotificationSchedule) {
                MHMutationStep.mainActor(name: "refreshNotificationSchedule") {
                    await refreshNotificationSchedule()
                }
            }

            if followUpHints.contains(.reloadWidgets) {
                MHMutationStep.mainActor(
                    name: "reloadWidgets",
                    action: reloadWidgets
                )
            }
        }
    }
}
