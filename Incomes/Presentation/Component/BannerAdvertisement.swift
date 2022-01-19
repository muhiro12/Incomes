//
//  BannerAdvertisement.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/15.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdvertisement: View {
    var body: some View {
        BannerAdmob()
            .frame(width: GADAdSizeBanner.size.width,
                   height: GADAdSizeBanner.size.height)
    }
}

private struct BannerAdmob: UIViewRepresentable {
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
struct BannerAdvertisement_Previews: PreviewProvider {
    static var previews: some View {
        BannerAdvertisement()
    }
}
#endif
