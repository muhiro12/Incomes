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

    private let layout: MHNativeAdLayout

    init(_ layout: MHNativeAdLayout) {
        self.layout = layout
    }
}

extension AdvertisementSection: View {
    var body: some View {
        if appRuntime.adsAvailability == .available {
            Section {
                appRuntime.nativeAdView(layout: layout)
                    .padding(designMetrics.spacing.inline)
            }
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    List {
        AdvertisementSection(.media)
        AdvertisementSection(.compact)
    }
}

#Preview("Ads unavailable") {
    List {
        Text(verbatim: "Content before ads")
        AdvertisementSection(.media)
        AdvertisementSection(.compact)
        Text(verbatim: "Content after ads")
    }
    .environment(MHAppRuntime(runtimeOnly: .init()))
}
