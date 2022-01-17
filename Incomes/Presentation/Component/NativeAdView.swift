//
//  NativeAdView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/15.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import Combine
import GoogleMobileAds

struct NativeAdView: View {
    @AppStorage(UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn = false

    var body: some View {
        if !isSubscribeOn {
            GeometryReader {
                AdmobNativeView(size: $0.size)
            }.aspectRatio(3, contentMode: .fit)
        }
    }
}

private final class AdmobNativeView: NSObject {
    private var size: CGSize
    private var view: GADNativeAdView?
    private var loader: GADAdLoader?

    init(size: CGSize) {
        self.size = size
    }
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

        let view = GADTSmallTemplateView()
        view.widthAnchor.constraint(equalToConstant: size.width).isActive = true
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
