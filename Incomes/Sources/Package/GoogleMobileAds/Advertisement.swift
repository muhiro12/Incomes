// // swiftlint:disable:this file_name
//  AdvertisementSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/17.
//

import MHPlatform
import SwiftUI

struct AdvertisementSection {
    enum Size: String {
        case small = "Small"
        case medium = "Medium"
    }

    @Environment(MHAppRuntime.self)
    private var appRuntime

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
                .padding(.space(.s))
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

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    List {
        AdvertisementSection(.medium)
        AdvertisementSection(.small)
    }
}
