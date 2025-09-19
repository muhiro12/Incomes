//
//  AdvertisementSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/17.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import GoogleMobileAdsWrapper
import SwiftUI

struct AdvertisementSection {
    enum Size: String {
        case small = "Small"
        case medium = "Medium"
    }

    @Environment(GoogleMobileAdsController.self)
    private var googleMobileAdsController

    private let size: Size

    init(_ size: Size) {
        self.size = size
    }
}

extension AdvertisementSection: View {
    var body: some View {
        Section {
            googleMobileAdsController.buildNativeAd(size.rawValue)
                .frame(maxWidth: .infinity)
                .padding(.space(.s))
        }
    }
}

#Preview {
    IncomesPreview { _ in
        List {
            AdvertisementSection(.medium)
            AdvertisementSection(.small)
        }
    }
}
