import Foundation

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
    static func perform(
        followUpHints: Set<MutationOutcome.FollowUpHint>,
        refreshNotificationSchedule: NotificationScheduleRefresher,
        reloadWidgets: @MainActor @Sendable () -> Void = {
            IncomesWidgetReloader.reloadAllWidgets()
        }
    ) async {
        if followUpHints.contains(.refreshNotificationSchedule) {
            await refreshNotificationSchedule()
        }

        if followUpHints.contains(.reloadWidgets) {
            reloadWidgets()
        }
    }
}
