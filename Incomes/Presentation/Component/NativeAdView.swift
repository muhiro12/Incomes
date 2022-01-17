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

    @State
    private var size = CGSize.zero

    var body: some View {
        if !isSubscribeOn {
            AdmobNativeView(size: $size)
                .frame(width: size.width, height: size.height)
        }
    }
}

private final class AdmobNativeView: NSObject {
    @Binding
    private var size: CGSize

    private var view: GADNativeAdView?
    private var loader: GADAdLoader?

    private var cancellables = Set<AnyCancellable>()

    init(size: Binding<CGSize>) {
        _size = size
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

        let view = GADTMediumTemplateView()
        view.widthAnchor.constraint(equalToConstant: 300).isActive = true
        view.publisher(for: \.bounds).sink {
            self.size = $0.size
        }.store(in: &cancellables)
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
