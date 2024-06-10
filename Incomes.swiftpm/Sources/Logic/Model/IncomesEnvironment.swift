//
//  IncomesEnvironment.swift
//
//
//  Created by Hiromu Nakano on 2024/06/08.
//

import SwiftUI

extension View {
    public func incomesEnvironment(
        groupID: String,
        productID: String,
        googleMobileAds: @escaping (String) -> some View,
        licenseList: @escaping () -> some View
    ) -> some View {
        self.environment(\.groupID, groupID)
            .environment(\.productID, productID)
            .environment(GoogleMobileAdsPackage(builder: googleMobileAds))
            .environment(LicenseListPackage(builder: licenseList))
    }

    func incomesPlaygroundsEnvironment() -> some View {
        incomesEnvironment(
            groupID: "groupID",
            productID: "productID",
            googleMobileAds: {
                Text("GoogleMobileAds \($0)")
            },
            licenseList: {
                Text("LicenseList")
            }
        )
    }
}
