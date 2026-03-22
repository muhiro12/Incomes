import MHPlatform

enum ItemMutationAdapterFactory {
    @MainActor
    static func make(
        notificationService: NotificationService,
        includesReviewRequest: Bool,
        reviewSource: String = #fileID
    ) -> MHMutationAdapter<Set<MutationOutcome.FollowUpHint>> {
        let refreshNotificationSchedule: IncomesMutationWorkflow.NotificationScheduleRefresher = {
            await IncomesMutationWorkflow.refreshNotificationSchedule(
                notificationService: notificationService
            )
        }
        let reviewStep = IncomesReviewSupport
            .flow(
                context: .itemMutation,
                source: reviewSource
            )
            .step(
                name: "scheduleReviewRequest"
            )

        var steps: [MHMutationStep] = [
            .mainActor(name: "successHaptic") {
                Haptic.success.impact()
            }
        ]
        if includesReviewRequest {
            steps.append(reviewStep)
        }

        return IncomesMutationWorkflow
            .followUpHintAdapter(
                refreshNotificationSchedule: refreshNotificationSchedule
            )
            .appending(steps)
    }
}
