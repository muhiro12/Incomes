//
//  AdView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/17.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct AdView: View {
    enum AdType {
        case banner
        case native
    }

    @AppStorage(UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn = false

    let type: AdType

    var body: some View {
        if !isSubscribeOn {
            switch type {
            case .banner:
                BannerAdView()
            case .native:
                HStack {
                    Spacer()
                    NativeAdView()
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
            }
        }
    }
}

#if DEBUG
struct AdView_Previews: PreviewProvider {
    static var previews: some View {
        AdView(type: .banner)
    }
}
#endif
