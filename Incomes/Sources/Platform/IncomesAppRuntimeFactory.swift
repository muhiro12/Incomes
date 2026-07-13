import MHAppRuntimeDefaults
import MHAppRuntimeLicenses
import MHPlatform

@MainActor
enum IncomesAppRuntimeFactory {
    static func make(
        configuration: MHAppConfiguration,
        adsConsentController: IncomesAdsConsentController
    ) -> MHAppRuntime {
        let defaultsBundle = MHAppRuntimeDefaultsBundle(
            configuration: configuration
        )
        let licensesBundle = MHAppRuntimeLicensesBundle(
            configuration: configuration
        )
        let subscriptionProductIDs = Set(configuration.subscriptionProductIDs)
        let startStore: MHAppRuntime.StartStore = { purchasedProductIDsDidSet in
            defaultsBundle.startStore { purchasedProductIDs in
                purchasedProductIDsDidSet(purchasedProductIDs)
                adsConsentController.setAdsEligibility(
                    subscriptionProductIDs.isDisjoint(with: purchasedProductIDs)
                )
            }
        }

        return .init(
            configuration: configuration,
            preferenceStore: defaultsBundle.preferenceStore,
            startStore: startStore,
            subscriptionSectionFactory: defaultsBundle.subscriptionSectionFactory,
            startAds: adsConsentController.makeStartAds(),
            nativeAdFactory: adsConsentController.makeNativeAdFactory(),
            licensesFactory: licensesBundle.licensesFactory
        )
    }
}
