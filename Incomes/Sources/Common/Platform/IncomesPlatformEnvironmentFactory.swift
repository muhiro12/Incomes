import GoogleMobileAdsWrapper
import LicenseListWrapper
import MHAppRuntimeCore
import MHDeepLinking
import MHPreferences
import MHReviewPolicy
import MHRouteExecution
import StoreKitWrapper
import SwiftData
import SwiftUI

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
        let appRuntime = makeAppRuntime(for: platformMode)
        let routePipeline = makeRoutePipeline(routeInbox: routeInbox)
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
            routeInbox: routeInbox,
            runtimeBootstrap: makeRuntimeBootstrap(
                runtime: appRuntime,
                routePipeline: routePipeline,
                remoteConfigurationService: remoteConfigurationService,
                notificationService: notificationService,
                reviewFlow: reviewFlow
            )
        )
    }

    @MainActor
    private static func makeAppRuntime(
        for platformMode: IncomesPlatformMode
    ) -> MHAppRuntime {
        let configuration: MHAppConfiguration = .init(
            subscriptionProductIDs: [Secret.productID],
            nativeAdUnitID: nativeAdUnitID(for: platformMode),
            preferencesSuiteName: AppGroup.id,
            showsLicenses: true
        )

        let store = Store()
        let nativeAdController = makeNativeAdController(
            nativeAdUnitID: configuration.nativeAdUnitID
        )
        let licensesViewBuilder: MHAppRuntime.LicensesViewBuilder = {
            if configuration.showsLicenses {
                return AnyView(LicenseListView())
            }

            return AnyView(EmptyView())
        }

        return .init(
            configuration: configuration,
            preferenceStore: makePreferenceStore(
                suiteName: configuration.preferencesSuiteName
            ),
            startStore: { purchasedProductIDsDidSet in
                store.open(
                    groupID: configuration.subscriptionGroupID,
                    productIDs: configuration.subscriptionProductIDs
                ) { products in
                    purchasedProductIDsDidSet(
                        Set(products.map(\.id))
                    )
                }
            },
            subscriptionSectionViewBuilder: {
                AnyView(store.buildSubscriptionSection())
            },
            startAds: makeAdsStarter(
                controller: nativeAdController
            ),
            nativeAdViewBuilder: makeNativeAdViewBuilder(
                controller: nativeAdController
            ),
            licensesViewBuilder: licensesViewBuilder
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

    private static func makePreferenceStore(
        suiteName: String?
    ) -> MHPreferenceStore {
        guard let suiteName,
              let userDefaults = UserDefaults(suiteName: suiteName) else {
            return .init()
        }

        return .init(userDefaults: userDefaults)
    }

    private static func makeNativeAdController(
        nativeAdUnitID: String?
    ) -> GoogleMobileAdsController? {
        guard let nativeAdUnitID else {
            return nil
        }

        return .init(adUnitID: nativeAdUnitID)
    }

    private static func makeAdsStarter(
        controller: GoogleMobileAdsController?
    ) -> MHAppRuntime.StartAds? {
        guard let controller else {
            return nil
        }

        return {
            controller.start()
        }
    }

    private static func makeNativeAdViewBuilder(
        controller: GoogleMobileAdsController?
    ) -> MHAppRuntime.NativeAdViewBuilder? {
        guard let controller else {
            return nil
        }

        return { size in
            AnyView(
                controller.buildNativeAd(
                    nativeAdSizeIdentifier(for: size)
                )
            )
        }
    }

    private static func nativeAdSizeIdentifier(
        for size: MHNativeAdSize
    ) -> String {
        switch size {
        case .small:
            "Small"
        case .medium:
            "Medium"
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
