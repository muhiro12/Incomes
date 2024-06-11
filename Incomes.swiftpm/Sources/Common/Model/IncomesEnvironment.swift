//
//  IncomesEnvironment.swift
//
//
//  Created by Hiromu Nakano on 2024/06/08.
//

import SwiftUI

extension View {
    public func incomesEnvironment(
        googleMobileAds: @escaping (String) -> some View,
        licenseList: @escaping () -> some View,
        storeKit: @escaping () -> some View
    ) -> some View {
        self.environment(GoogleMobileAdsPackage(builder: googleMobileAds))
            .environment(LicenseListPackage(builder: licenseList))
            .environment(StoreKitPackage(builder: storeKit))
    }

    func incomesPlaygroundsEnvironment() -> some View {
        incomesEnvironment(
            googleMobileAds: {
                Text("GoogleMobileAds \($0)")
            },
            licenseList: {
                Text("LicenseList")
            },
            storeKit: {
                Text("StoreKit")
            }
        )
    }
}
