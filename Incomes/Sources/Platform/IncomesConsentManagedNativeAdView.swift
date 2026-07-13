import GoogleMobileAdsWrapper
import MHPlatform
import SwiftUI

@MainActor
struct IncomesConsentManagedNativeAdView: View {
    let consentController: IncomesAdsConsentController
    let mobileAdsController: GoogleMobileAdsController
    let size: MHNativeAdSize

    var body: some View {
        if consentController.isAdsReady {
            mobileAdsController.buildNativeAd(size.incomesWrapperSizeID)
        }
    }
}

private extension MHNativeAdSize {
    var incomesWrapperSizeID: String {
        switch self {
        case .small:
            "Small"
        case .medium:
            "Medium"
        }
    }
}
