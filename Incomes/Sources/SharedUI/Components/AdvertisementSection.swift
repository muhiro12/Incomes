//
//  AdvertisementSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/17.
//

import MHPlatform
import SwiftUI

struct AdvertisementSection {
    @Environment(MHAppRuntime.self)
    private var appRuntime
    private let layout: MHNativeAdLayout

    init(_ layout: MHNativeAdLayout) {
        self.layout = layout
    }
}

extension AdvertisementSection: View {
    var body: some View {
        if appRuntime.canDisplayAds {
            Section {
                appRuntime.nativeAdView(layout: layout)
                    .listRowInsets(.init())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
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
