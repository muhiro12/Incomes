import Foundation
import MHPlatform

enum IncomesMutationWorkflow {
    typealias NotificationScheduleRefresher = @MainActor @Sendable () async -> Void
    typealias WatchSnapshotRefresher = @MainActor @Sendable () -> Void

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
        },
        refreshWatchSnapshot: @escaping WatchSnapshotRefresher = {
            PhoneWatchBridge.shared.requestSnapshotRefresh()
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

            if followUpHints.contains(.refreshWatchSnapshot) {
                MHMutationStep.mainActor(
                    name: "refreshWatchSnapshot",
                    action: refreshWatchSnapshot
                )
            }
        }
    }
}
