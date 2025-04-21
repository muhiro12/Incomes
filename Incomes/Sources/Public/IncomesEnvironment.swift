//
//  IncomesEnvironment.swift
//
//
//  Created by Hiromu Nakano on 2024/06/08.
//

import SwiftUI

public extension View {
    func incomesEnvironment(
        googleMobileAds: @escaping (String) -> some View,
        licenseList: @escaping () -> some View,
        storeKit: @escaping () -> some View,
        appIntents: @escaping () -> some View
    ) -> some View {
        self.environment(GoogleMobileAdsPackage(builder: googleMobileAds))
            .environment(LicenseListPackage(builder: licenseList))
            .environment(StoreKitPackage(builder: storeKit))
            .environment(AppIntentsPackage(builder: appIntents))
    }
}
