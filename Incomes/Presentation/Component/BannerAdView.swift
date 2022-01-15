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
    @AppStorage(UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn = false

    var body: some View {
        if !isSubscribeOn {
            AdmobBannerView()
                .frame(width: GADAdSizeBanner.size.width,
                       height: GADAdSizeBanner.size.height)
        }
    }
}

private struct AdmobBannerView: UIViewRepresentable {
    typealias UIViewType = GADBannerView

    func makeUIView(context: Context) -> UIViewType {
        let view = GADBannerView(adSize: GADAdSizeBanner)
        view.adUnitID = EnvironmentParameter.admobBannerID
        view.rootViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
        view.load(GADRequest())
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

#if DEBUG
struct BannerAdView_Previews: PreviewProvider {
    static var previews: some View {
        BannerAdView()
    }
}
#endif
