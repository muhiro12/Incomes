//
//  AdvertisementSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/17.
//

import MHDesign
import MHPlatform
import SwiftUI

struct AdvertisementSection {
    enum Size: String {
        case small = "Small"
        case medium = "Medium"
    }

    @Environment(MHAppRuntime.self)
    private var appRuntime
    @Environment(IncomesAdsConsentController.self)
    private var adsConsentController
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let size: Size

    init(_ size: Size) {
        self.size = size
    }
}

extension AdvertisementSection: View {
    @ViewBuilder var body: some View {
        if appRuntime.premiumStatus == .inactive,
           adsConsentController.isAdsReady {
            Section {
                appRuntime.nativeAdView(size: size.runtimeSize)
                    .frame(maxWidth: .infinity)
                    .padding(designMetrics.spacing.inline)
            }
        }
    }
}

private extension AdvertisementSection.Size {
    var runtimeSize: MHNativeAdSize {
        switch self {
        case .small:
            .small
        case .medium:
            .medium
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    List {
        AdvertisementSection(.medium)
        AdvertisementSection(.small)
    }
}
