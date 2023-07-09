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
                return .componentM
            case .medium:
                return 320
            }
        }
    }

    let size: Size

    var body: some View {
        NativeAdmob(size: size)
            .frame(maxWidth: 360,
                   minHeight: size.height)
    }
}

#if DEBUG
struct NativeAdvertisement_Previews: PreviewProvider {
    static var previews: some View {
        NativeAdvertisement(size: .medium)
    }
}
#endif

// MARK: - UIViewRepresentable

private struct NativeAdmob {
    let size: NativeAdvertisement.Size
}

extension NativeAdmob: UIViewRepresentable {
    typealias UIViewType = UIView

    func makeUIView(context: Context) -> UIViewType {
        let view = NativeAdmobView(size: size)
        return view
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
            fatalError()
        }
        view.frame = bounds
        view.isHidden = true
        addSubview(view)
        self.view = view

        let loader = GADAdLoader(adUnitID: EnvironmentParameter.admobNativeID,
                                 rootViewController: (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController,
                                 adTypes: [.native],
                                 options: nil)
        loader.delegate = self
        loader.load(GADRequest())
        self.loader = loader
    }

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
