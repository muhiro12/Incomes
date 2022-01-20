//
//  NativeAdvertisement.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/15.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

struct NativeAdvertisement: View {
    enum Size: String {
        case small = "Small"
        case medium = "Medium"

        var height: CGFloat {
            switch self {
            case .small:
                return .componentL
            case .medium:
                return 240
            }
        }
    }

    let size: Size

    var body: some View {
        NativeAdmob(size: size)
            .frame(height: size.height)
    }
}

private final class NativeAdmob: NSObject {
    private let size: NativeAdvertisement.Size
    private var view: GADNativeAdView?
    private var loader: GADAdLoader?

    init(size: NativeAdvertisement.Size) {
        self.size = size
    }
}

extension NativeAdmob: UIViewRepresentable {
    typealias UIViewType = GADNativeAdView

    func makeUIView(context: Context) -> UIViewType {
        guard let view = UINib(nibName: size.rawValue + String(describing: type(of: self)), bundle: nil)
                .instantiate(withOwner: self, options: nil).first as? GADNativeAdView
        else {
            assertionFailure()
            return .init()
        }
        view.isHidden = true
        self.view = view

        let loader = GADAdLoader(adUnitID: EnvironmentParameter.admobNativeID,
                                 rootViewController: (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController,
                                 adTypes: [.native],
                                 options: nil)
        loader.delegate = self
        loader.load(GADRequest())
        self.loader = loader

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

extension NativeAdmob: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        if let mediaView = view?.mediaView {
            mediaView.widthAnchor
                .constraint(equalTo: mediaView.heightAnchor,
                            multiplier: nativeAd.mediaContent.aspectRatio)
                .isActive = true
        }

        view?.mediaView?.mediaContent = nativeAd.mediaContent
        (view?.headlineView as? UILabel)?.text = nativeAd.headline
        (view?.advertiserView as? UILabel)?.text = nativeAd.advertiser
        (view?.callToActionView as? UILabel)?.text = nativeAd.callToAction
        view?.nativeAd = nativeAd

        view?.isHidden = false
    }

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        view?.isHidden = true
    }
}

#if DEBUG
struct NativeAdvertisement_Previews: PreviewProvider {
    static var previews: some View {
        NativeAdvertisement(size: .medium)
    }
}
#endif
