import MHPlatform
import SwiftData

enum IncomesPlatformEnvironmentFactory {
    static func makeAppModelContainer(
        isICloudEnabled: Bool
    ) throws -> ModelContainer {
        try ModelContainer(
            for: Item.self,
            configurations: .init(
                url: Database.url,
                cloudKitDatabase: isICloudEnabled ? .automatic : .none
            )
        )
    }

    static func makePreviewModelContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Item.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
    }

    @MainActor
    static func make(
        modelContainer: ModelContainer,
        platformMode: IncomesPlatformMode
    ) -> IncomesPlatformEnvironment {
        let routeInbox = IncomesRouteInbox()
        let appRuntime = MHAppRuntime(
            configuration: .init(
                subscriptionProductIDs: [Secret.productID],
                nativeAdUnitID: nativeAdUnitID(for: platformMode),
                preferencesSuiteName: AppGroup.id,
                showsLicenses: true
            )
        )
        let routePipeline = MHAppRoutePipeline(
            routeLifecycle: .init(
                logger: IncomesApp.logger(
                    category: "RouteExecution",
                    source: #fileID
                ),
                initialReadiness: false,
                isDuplicate: ==
            ),
            using: IncomesDeepLinkCodec.shared,
            pendingSources: pendingURLSources()
        ) { route in
            routeInbox.ingest(route)
        }
        let notificationService = NotificationService(
            modelContainer: modelContainer,
            routeDestination: routePipeline.inbox
        )
        let configurationService = ConfigurationService()
        let tipController = IncomesTipController()
        let reviewFlow = IncomesReviewSupport.flow(
            context: .appActivation,
            source: #fileID
        )

        configureTipControllerIfNeeded(tipController)

        return .init(
            modelContainer: modelContainer,
            notificationService: notificationService,
            configurationService: configurationService,
            tipController: tipController,
            routeInbox: routeInbox,
            runtimeBootstrap: makeRuntimeBootstrap(
                runtime: appRuntime,
                routePipeline: routePipeline,
                configurationService: configurationService,
                notificationService: notificationService,
                reviewFlow: reviewFlow
            )
        )
    }

    private static func pendingURLSources() -> [any MHDeepLinkURLSource] {
        var sources = [any MHDeepLinkURLSource]()

        if let intentRouteSource = IncomesIntentRouteStore.source {
            sources.append(intentRouteSource)
        }

        return sources
    }

    private static func nativeAdUnitID(
        for platformMode: IncomesPlatformMode
    ) -> String {
        switch platformMode {
        case .production:
            #if DEBUG
            Secret.admobNativeIDDev
            #else
            Secret.admobNativeID
            #endif
        case .preview:
            Secret.admobNativeIDDev
        }
    }

    @MainActor
    private static func makeRuntimeBootstrap(
        runtime: MHAppRuntime,
        routePipeline: MHAppRoutePipeline<IncomesRoute>,
        configurationService: ConfigurationService,
        notificationService: NotificationService,
        reviewFlow: MHReviewFlow
    ) -> MHAppRuntimeBootstrap {
        .init(
            runtime: runtime,
            lifecyclePlan: .init(
                commonTasks: [
                    .init(name: "loadConfiguration") {
                        try? await configurationService.load()
                    },
                    .init(name: "updateNotifications") {
                        await notificationService.update()
                    },
                    routePipeline.task(
                        name: "synchronizePendingRoutes"
                    )
                ],
                activeTasks: [
                    reviewFlow.task(name: "requestReview")
                ],
                skipFirstActivePhase: true
            ),
            routePipeline: routePipeline
        )
    }

    private static func configureTipControllerIfNeeded(
        _ tipController: IncomesTipController
    ) {
        do {
            try tipController.configureIfNeeded()
        } catch {
            #if DEBUG
            assertionFailure(error.localizedDescription)
            #endif
        }
    }
}
