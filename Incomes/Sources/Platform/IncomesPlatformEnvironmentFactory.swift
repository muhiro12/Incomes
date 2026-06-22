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
        platformMode: IncomesPlatformMode,
        logging: MHLoggingBootstrap
    ) -> IncomesPlatformEnvironment {
        let routeInbox = makeRouteInbox()
        let routePipeline = makeRoutePipeline(
            routeInbox: routeInbox,
            logging: logging
        )
        let notificationService = NotificationService(
            modelContainer: modelContainer,
            routeDestination: routePipeline.inbox,
            logging: logging
        )
        let remoteConfigurationService = RemoteConfigurationService(
            logger: IncomesLogging.logger(
                logging: logging,
                category: IncomesLogging.Category.remoteConfiguration,
                source: #fileID
            )
        )
        let tipController = makeTipController(for: platformMode)
        let reviewFlow = IncomesReviewSupport.flow(
            context: .appActivation,
            logging: logging,
            source: #fileID
        )

        return .init(
            logging: logging,
            modelContainer: modelContainer,
            notificationService: notificationService,
            remoteConfigurationService: remoteConfigurationService,
            tipController: tipController,
            routeInbox: routeInbox,
            routePipeline: routePipeline,
            runtimeBootstrap: makeRuntimeBootstrap(
                configuration: makeAppConfiguration(for: platformMode),
                routePipeline: routePipeline,
                remoteConfigurationService: remoteConfigurationService,
                notificationService: notificationService,
                reviewFlow: reviewFlow
            )
        )
    }

    private static func makeAppConfiguration(
        for platformMode: IncomesPlatformMode
    ) -> MHAppConfiguration {
        .init(
            subscriptionProductIDs: [
                IncomesMonetizationConfiguration.subscriptionProductID
            ],
            nativeAdUnitID: nativeAdUnitID(for: platformMode),
            showsLicenses: true
        )
    }

    @MainActor
    private static func makeRouteInbox() -> IncomesRouteInbox {
        .init(
            isDuplicate: { route, otherRoute in
                route == otherRoute
            },
            onFailure: { _, error in
                assertionFailure(error.localizedDescription)
            }
        )
    }

    @MainActor
    private static func makeRoutePipeline(
        routeInbox: IncomesRouteInbox,
        logging: MHLoggingBootstrap
    ) -> MHAppRoutePipeline<IncomesRoute> {
        MHAppRoutePipeline(
            routeLifecycle: MHRouteLifecycle<IncomesRoute>(
                logger: IncomesLogging.logger(
                    logging: logging,
                    category: IncomesLogging.Category.routeExecution,
                    source: #fileID
                ),
                initialReadiness: false
            ) { route, otherRoute in
                route == otherRoute
            },
            using: IncomesDeepLinkCodec.shared,
            routeInbox: routeInbox,
            pendingSources: pendingURLSources()
        ) { error in
            handleRoutePipelineFailure(
                error,
                logger: IncomesLogging.logger(
                    logging: logging,
                    category: IncomesLogging.Category.routeExecution,
                    source: #fileID
                )
            )
        }
    }

    @MainActor
    private static func handleRoutePipelineFailure(
        _ error: any Error,
        logger: MHLogger
    ) {
        logger.error(
            "route_pipeline.failure",
            metadata: IncomesLogging.errorMetadata(error)
        )
        assertionFailure(error.localizedDescription)
    }

    private static func pendingURLSources() -> [any MHDeepLinkURLSource] {
        var sources = [any MHDeepLinkURLSource]()

        if let intentRouteSource = IncomesIntentRouteStore.source {
            sources.append(intentRouteSource)
        }

        return sources
    }

    private static func makeTipController(
        for platformMode: IncomesPlatformMode
    ) -> IncomesTipController {
        let tipController = IncomesTipController()
        configureTipControllerIfNeeded(
            tipController,
            hideAllTipsForTesting: platformMode == .preview
        )
        return tipController
    }

    private static func nativeAdUnitID(
        for platformMode: IncomesPlatformMode
    ) -> String {
        switch platformMode {
        case .production:
            #if DEBUG
            IncomesMonetizationConfiguration.nativeAdUnitIDDev
            #else
            IncomesMonetizationConfiguration.nativeAdUnitID
            #endif
        case .preview:
            IncomesMonetizationConfiguration.nativeAdUnitIDDev
        }
    }

    @MainActor
    private static func makeRuntimeBootstrap(
        configuration: MHAppConfiguration,
        routePipeline: MHAppRoutePipeline<IncomesRoute>,
        remoteConfigurationService: RemoteConfigurationService,
        notificationService: NotificationService,
        reviewFlow: MHReviewFlow
    ) -> MHAppRuntimeBootstrap {
        .init(
            configuration: configuration,
            lifecyclePlan: .init(
                commonTasks: [
                    .init(name: "loadRemoteConfiguration") {
                        try? await remoteConfigurationService.load()
                    },
                    .init(name: "updateNotifications") {
                        await notificationService.update()
                    }
                ],
                activeTasks: [
                    routePipeline.task(
                        name: "synchronizePendingRoutes"
                    ),
                    reviewFlow.task(name: "requestReview")
                ],
                skipFirstActivePhase: true
            ),
            routePipeline: routePipeline
        )
    }

    private static func configureTipControllerIfNeeded(
        _ tipController: IncomesTipController,
        hideAllTipsForTesting: Bool
    ) {
        do {
            try tipController.configureIfNeeded(
                hideAllTipsForTesting: hideAllTipsForTesting
            )
        } catch {
            #if DEBUG
            assertionFailure(error.localizedDescription)
            #endif
        }
    }
}
