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
        let notificationService = NotificationService(modelContainer: modelContainer)
        let configurationService = ConfigurationService()
        let tipController = IncomesTipController()

        do {
            try tipController.configureIfNeeded()
        } catch {
            #if DEBUG
            assertionFailure(error.localizedDescription)
            #endif
        }

        return .init(
            modelContainer: modelContainer,
            notificationService: notificationService,
            configurationService: configurationService,
            tipController: tipController,
            appRuntime: .init(
                configuration: .init(
                    subscriptionProductIDs: [Secret.productID],
                    nativeAdUnitID: nativeAdUnitID(for: platformMode),
                    preferencesSuiteName: AppGroup.id,
                    showsLicenses: true
                )
            )
        )
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
}
