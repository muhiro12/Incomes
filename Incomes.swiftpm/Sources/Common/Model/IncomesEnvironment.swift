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
                placeholder("GoogleMobileAds \($0)")
            },
            licenseList: {
                placeholder("LicenseList")
            },
            storeKit: {
                placeholder("StoreKit")
            }
        )
    }

    private func placeholder(_ string: String) -> some View {
        Text(string)
            .frame(width: 240, height: 160)
            .font(.headline)
            .foregroundStyle(.placeholder)
            .background(.placeholder.quinary)
            .clipShape(.rect(cornerRadius: 8))
            .padding()
    }        
}
