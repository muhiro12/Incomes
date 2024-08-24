//
//  Advertisement.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/17.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct Advertisement {
    enum Size: String {
        case small = "Small"
        case medium = "Medium"
    }

    @Environment(GoogleMobileAdsPackage.self) private var googleMobileAds

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    private let size: Size

    init(_ size: Size) {
        self.size = size
    }
}

extension Advertisement: View {
    var body: some View {
        if !isSubscribeOn {
            HStack {
                Spacer()
                googleMobileAds(size.rawValue)
                    .border(Color(UIColor.separator))
                Spacer()
            }
            .listRowBackground(Color.clear)
            .listSectionSeparator(.hidden)
        }
    }
}

#Preview {
    List {
        Advertisement(.medium)
    }
}
