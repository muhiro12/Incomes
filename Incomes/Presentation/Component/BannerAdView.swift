//
//  BannerAdView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/15.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: View {
    var body: some View {
        BannerAdmobView()
            .frame(width: GADAdSizeBanner.size.width,
                   height: GADAdSizeBanner.size.height)
    }

    private struct BannerAdmobView: UIViewRepresentable {
        func makeUIView(context: Context) -> GADBannerView {
            let view = GADBannerView(adSize: GADAdSizeBanner)
            view.adUnitID = EnvironmentParameter.admobBannerID
            view.rootViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
            view.load(GADRequest())
            return view
        }

        func updateUIView(_ uiView: GADBannerView, context: Context) {}
    }
}

#if DEBUG
struct BannerAdView_Previews: PreviewProvider {
    static var previews: some View {
        BannerAdView()
    }
}
#endif
