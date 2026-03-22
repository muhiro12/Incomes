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
        let routeInbox = makeRouteInbox()
        let routePipeline = makeRoutePipeline(routeInbox: routeInbox)
        let notificationService = NotificationService(
            modelContainer: modelContainer,
            routeDestination: routePipeline.inbox
        )
        let remoteConfigurationService = RemoteConfigurationService()
        let tipController = makeTipController(for: platformMode)
        let reviewFlow = IncomesReviewSupport.flow(
            context: .appActivation,
            source: #fileID
        )

        return .init(
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
            subscriptionProductIDs: [Secret.productID],
            nativeAdUnitID: nativeAdUnitID(for: platformMode),
            preferencesSuiteName: AppGroup.id,
            showsLicenses: true
        )
    }

    @MainActor
    private static func makeRouteInbox() -> IncomesRouteInbox {
        .init(
            isDuplicate: ==
        ) { _, error in
            assertionFailure(error.localizedDescription)
        }
    }

    @MainActor
    private static func makeRoutePipeline(
        routeInbox: IncomesRouteInbox
    ) -> MHAppRoutePipeline<IncomesRoute> {
        MHAppRoutePipeline(
            routeLifecycle: .init(
                logger: IncomesApp.logger(
                    category: "RouteExecution",
                    source: #fileID
                ),
                initialReadiness: false,
                isDuplicate: ==
            ),
            using: IncomesDeepLinkCodec.shared,
            routeInbox: routeInbox,
            pendingSources: pendingURLSources()
        ) { error in
            handleRoutePipelineFailure(error)
        }
    }

    @MainActor
    private static func handleRoutePipelineFailure(
        _ error: any Error
    ) {
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
