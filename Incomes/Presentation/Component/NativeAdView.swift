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
    var body: some View {
        GeometryReader {
            AdmobNativeView(size: $0.size)
        }.frame(height: AdmobNativeView.estimatedHeight)
    }
}

private final class AdmobNativeView: NSObject {
    static let estimatedHeight: CGFloat = 105

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
