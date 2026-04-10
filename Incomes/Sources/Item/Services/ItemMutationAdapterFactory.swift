import MHPlatform

enum ItemMutationAdapterFactory {
    @MainActor
    static func make(
        notificationService: NotificationService,
        includesReviewRequest: Bool,
        reviewLogger: MHLogger? = nil
    ) -> MHMutationAdapter<Set<MutationOutcome.FollowUpHint>> {
        let refreshNotificationSchedule: IncomesMutationWorkflow.NotificationScheduleRefresher = {
            await IncomesMutationWorkflow.refreshNotificationSchedule(
                notificationService: notificationService
            )
        }

        var steps: [MHMutationStep] = [
            .mainActor(name: "successHaptic") {
                Haptic.success.impact()
            }
        ]
        if includesReviewRequest {
            guard let reviewLogger else {
                preconditionFailure("reviewLogger is required when includesReviewRequest is true")
            }
            steps.append(
                MHReviewFlow(
                    policy: IncomesReviewSupport.policy(for: .itemMutation),
                    logger: reviewLogger
                )
                .step(
                    name: "scheduleReviewRequest"
                )
            )
        }

        return IncomesMutationWorkflow
            .followUpHintAdapter(
                refreshNotificationSchedule: refreshNotificationSchedule
            )
            .appending(steps)
    }
}
