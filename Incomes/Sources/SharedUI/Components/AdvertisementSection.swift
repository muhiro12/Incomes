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
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let size: Size

    init(_ size: Size) {
        self.size = size
    }
}

extension AdvertisementSection: View {
    var body: some View {
        Section {
            appRuntime.nativeAdView(size: size.runtimeSize)
                .frame(maxWidth: .infinity)
                .padding(designMetrics.spacing.inline)
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
