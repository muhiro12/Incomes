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
    @Environment(MHAppRuntime.self)
    private var appRuntime
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let size: MHNativeAdSize

    init(_ size: MHNativeAdSize) {
        self.size = size
    }
}

extension AdvertisementSection: View {
    var body: some View {
        if appRuntime.adsAvailability == .available {
            Section {
                appRuntime.nativeAdView(size: size)
                    .frame(maxWidth: .infinity)
                    .padding(designMetrics.spacing.inline)
            }
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    List {
        AdvertisementSection(.medium)
        AdvertisementSection(.small)
    }
}

#Preview("Ads unavailable") {
    List {
        Text(verbatim: "Content before ads")
        AdvertisementSection(.medium)
        AdvertisementSection(.small)
        Text(verbatim: "Content after ads")
    }
    .environment(MHAppRuntime(runtimeOnly: .init()))
}
