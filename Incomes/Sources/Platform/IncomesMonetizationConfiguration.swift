//
//  IncomesMonetizationConfiguration.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2026/04/14.
//

import Foundation
import MHPlatform

enum IncomesMonetizationConfiguration {
    static let subscriptionProductID = "com.muhiro12.Incomes.subscriptions.monthly"
    static let nativeAdUnitID = "ca-app-pub-2619807738023307/6289245055"
    static let nativeAdUnitIDDev = "ca-app-pub-3940256099942544/3986624511"

    /// Keeps regional consent verification out of distribution builds.
    static var adsConsent: MHAdsConsentConfiguration {
        #if DEBUG
        .init(
            debugGeography: ProcessInfo.processInfo
                .environment["INCOMES_ADS_CONSENT_DEBUG_GEOGRAPHY"]
                .flatMap(MHAdsConsentConfiguration.DebugGeography.init(rawValue:))
        )
        #else
        .init()
        #endif
    }
}
