import MHPlatform

enum ItemMutationAdapterFactory {
    @MainActor
    static func makeForSave(
        notificationService: NotificationService,
        reviewLogger: MHLogger
    ) -> MHMutationAdapter<Set<MutationOutcome.FollowUpHint>> {
        make(
            notificationService: notificationService,
            additionalSteps: [
                successHapticStep(),
                reviewRequestStep(logger: reviewLogger)
            ]
        )
    }

    @MainActor
    static func makeForDelete(
        notificationService: NotificationService
    ) -> MHMutationAdapter<Set<MutationOutcome.FollowUpHint>> {
        make(
            notificationService: notificationService,
            additionalSteps: [
                successHapticStep()
            ]
        )
    }
}

private extension ItemMutationAdapterFactory {
    @MainActor
    static func make(
        notificationService: NotificationService,
        additionalSteps: [MHMutationStep]
    ) -> MHMutationAdapter<Set<MutationOutcome.FollowUpHint>> {
        let refreshNotificationSchedule: IncomesMutationWorkflow.NotificationScheduleRefresher = {
            await IncomesMutationWorkflow.refreshNotificationSchedule(
                notificationService: notificationService
            )
        }

        return IncomesMutationWorkflow
            .followUpHintAdapter(
                refreshNotificationSchedule: refreshNotificationSchedule
            )
            .appending(additionalSteps)
    }

    static func successHapticStep() -> MHMutationStep {
        .mainActor(name: "successHaptic") {
            Haptic.success.impact()
        }
    }

    static func reviewRequestStep(logger: MHLogger) -> MHMutationStep {
        MHReviewFlow(
            policy: IncomesReviewSupport.policy(for: .itemMutation),
            logger: logger
        )
        .step(
            name: "scheduleReviewRequest"
        )
    }
}
