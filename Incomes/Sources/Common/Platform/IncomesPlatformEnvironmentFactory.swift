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
        let routeBridge = IncomesRouteBridge()
        let appRuntime = makeAppRuntime(for: platformMode)
        let routePipeline = makeRoutePipeline(routeBridge: routeBridge)
        let notificationService = NotificationService(
            modelContainer: modelContainer,
            routeDestination: routePipeline.inbox
        )
        let remoteConfigurationService = RemoteConfigurationService()
        let tipController = makeTipController()
        let reviewFlow = IncomesReviewSupport.flow(
            context: .appActivation,
            source: #fileID
        )

        return .init(
            modelContainer: modelContainer,
            notificationService: notificationService,
            remoteConfigurationService: remoteConfigurationService,
            tipController: tipController,
            routeBridge: routeBridge,
            runtimeBootstrap: makeRuntimeBootstrap(
                runtime: appRuntime,
                routePipeline: routePipeline,
                remoteConfigurationService: remoteConfigurationService,
                notificationService: notificationService,
                reviewFlow: reviewFlow
            )
        )
    }

    private static func makeAppRuntime(
        for platformMode: IncomesPlatformMode
    ) -> MHAppRuntime {
        .init(
            configuration: .init(
                subscriptionProductIDs: [Secret.productID],
                nativeAdUnitID: nativeAdUnitID(for: platformMode),
                preferencesSuiteName: AppGroup.id,
                showsLicenses: true
            )
        )
    }

    @MainActor
    private static func makeRoutePipeline(
        routeBridge: IncomesRouteBridge
    ) -> MHAppRoutePipeline<IncomesRoute> {
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
            try await routeBridge.apply(route)
        } onFailure: { error in
            handleRoutePipelineFailure(error)
        }

        routeBridge.configureResynchronization {
            _ = await routePipeline.synchronizePendingRoutesIfPossible()
        }

        return routePipeline
    }

    @MainActor
    private static func handleRoutePipelineFailure(
        _ error: any Error
    ) {
        if error is IncomesRouteBridge.HandlerUnavailableError {
            let logger = IncomesApp.logger(
                category: "RouteExecution",
                source: #fileID
            )
            logger.info("route handling deferred until main navigation is ready")
            return
        }

        assertionFailure(error.localizedDescription)
    }

    private static func pendingURLSources() -> [any MHDeepLinkURLSource] {
        var sources = [any MHDeepLinkURLSource]()

        if let intentRouteSource = IncomesIntentRouteStore.source {
            sources.append(intentRouteSource)
        }

        return sources
    }

    private static func makeTipController() -> IncomesTipController {
        let tipController = IncomesTipController()
        configureTipControllerIfNeeded(tipController)
        return tipController
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
        remoteConfigurationService: RemoteConfigurationService,
        notificationService: NotificationService,
        reviewFlow: MHReviewFlow
    ) -> MHAppRuntimeBootstrap {
        .init(
            runtime: runtime,
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
