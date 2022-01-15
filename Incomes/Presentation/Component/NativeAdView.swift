//
//  NativeAdView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/15.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

struct NativeAdView: View {
    @AppStorage(UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn = false

    var body: some View {
        if !isSubscribeOn {
            AdmobNativeView()
                .aspectRatio(2, contentMode: .fit)
        }
    }
}

private final class AdmobNativeView: NSObject {
    private var view: GADNativeAdView?
    private var loader: GADAdLoader?
}

extension AdmobNativeView: UIViewRepresentable {
    typealias UIViewType = GADNativeAdView

    func makeUIView(context: Context) -> UIViewType {
        let loader = GADAdLoader(adUnitID: EnvironmentParameter.admobNativeID,
                                 rootViewController: (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController,
                                 adTypes: [.native],
                                 options: nil)
        loader.delegate = self
        loader.load(GADRequest())
        self.loader = loader

        let view = GADNativeAdView()
        self.view = view

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

extension AdmobNativeView: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        view?.nativeAd = nativeAd
    }

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {}
}

#if DEBUG
struct NativeAdView_Previews: PreviewProvider {
    static var previews: some View {
        NativeAdView()
    }
}
#endif
