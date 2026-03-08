import MHPlatform

enum IncomesRuntimeLifecycleSupport {
    static func makePlan(
        syncSubscriptionStateIfNeeded: @escaping @MainActor @Sendable () -> Void,
        refreshConfigurationState: @escaping @MainActor @Sendable () async -> Void,
        updateNotifications: @escaping @MainActor @Sendable () async -> Void,
        requestReviewIfNeeded: @escaping @MainActor @Sendable () async -> Void,
        applyPendingDeepLinkIfNeeded: @escaping @Sendable () async -> Void
    ) -> MHAppRuntimeLifecyclePlan {
        .init(
            startupTasks: [
                .init(name: "syncSubscriptionState") {
                    syncSubscriptionStateIfNeeded()
                },
                .init(name: "loadConfiguration") {
                    await refreshConfigurationState()
                },
                .init(name: "updateNotifications") {
                    await updateNotifications()
                },
                .init(name: "applyPendingDeepLink") {
                    await applyPendingDeepLinkIfNeeded()
                }
            ],
            activeTasks: [
                .init(name: "syncSubscriptionState") {
                    syncSubscriptionStateIfNeeded()
                },
                .init(name: "loadConfiguration") {
                    await refreshConfigurationState()
                },
                .init(name: "updateNotifications") {
                    await updateNotifications()
                },
                .init(name: "requestReview") {
                    await requestReviewIfNeeded()
                },
                .init(name: "applyPendingDeepLink") {
                    await applyPendingDeepLinkIfNeeded()
                }
            ],
            skipFirstActivePhase: true
        )
    }
}
