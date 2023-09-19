//
//  NativeAdmob.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/15.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import GoogleMobileAds
import SwiftUI

// swiftlint:disable file_types_order
struct NativeAdmob {
    let size: NativeAdvertisement.Size
}

extension NativeAdmob: UIViewRepresentable {
    typealias UIViewType = UIView

    func makeUIView(context: Context) -> UIViewType {
        NativeAdmobView(size: size)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

// MARK: - GADNativeAdView

private final class NativeAdmobView: UIView {
    private let size: NativeAdvertisement.Size
    private var view: GADNativeAdView?
    private var loader: GADAdLoader?

    init(size: NativeAdvertisement.Size) {
        self.size = size

        super.init(frame: .zero)

        guard let view = UINib(nibName: size.rawValue + String(describing: type(of: self)), bundle: nil)
                .instantiate(withOwner: self, options: nil).first as? GADNativeAdView
        else {
            assertionFailure("Failed to init GADNativeAdView")
            return
        }
        view.frame = bounds
        view.isHidden = true
        addSubview(view)
        self.view = view

        let rootVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows
            .first?
            .rootViewController
        let loader = GADAdLoader(
            adUnitID: EnvironmentParameter.admobNativeID,
            rootViewController: rootVC,
            adTypes: [.native],
            options: size == .small ? [GADNativeAdImageAdLoaderOptions()] : nil
        )
        loader.delegate = self
        loader.load(GADRequest())
        self.loader = loader
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NativeAdmobView: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        if let mediaView = view?.mediaView {
            mediaView.widthAnchor
                .constraint(equalTo: mediaView.heightAnchor,
                            multiplier: nativeAd.mediaContent.aspectRatio)
                .isActive = true
        }

        (view?.headlineView as? UILabel)?.text = nativeAd.headline
        (view?.callToActionView as? UILabel)?.text = nativeAd.callToAction
        (view?.bodyView as? UILabel)?.text = nativeAd.body
        (view?.advertiserView as? UILabel)?.text = nativeAd.advertiser
        view?.mediaView?.mediaContent = nativeAd.mediaContent
        view?.nativeAd = nativeAd

        view?.isHidden = false
    }

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        view?.isHidden = true
    }
}
// swiftlint:enable file_types_order
