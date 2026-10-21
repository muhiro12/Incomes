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
    @State private var isAdVisible = false
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
                    .onGeometryChange(for: Bool.self) { geometry in
                        geometry.size.height > .zero
                    } action: { isVisible in
                        isAdVisible = isVisible
                    }
                    .padding(.horizontal, designMetrics.spacing.inline)
                    .padding(.vertical, isAdVisible ? designMetrics.spacing.inline : .zero)
                    .listRowInsets(.init())
                    .listRowBackground(isAdVisible ? Color(uiColor: .secondarySystemGroupedBackground) : .clear)
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
