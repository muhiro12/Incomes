//
//  IncomesApp.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Firebase
import IncomesPackages
import IncomesPlaygrounds
import SwiftUI

@main
struct IncomesApp: App {
    private let sharedGoogleMobileAdsController: GoogleMobileAdsController

    init() {
        FirebaseApp.configure()

        sharedGoogleMobileAdsController = .init(
            adUnitID: {
                #if DEBUG
                Secret.admobNativeIDDev.rawValue
                #else
                Secret.admobNativeID.rawValue
                #endif
            }()
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .incomesEnvironment(
                    groupID: Secret.groupID.rawValue,
                    productID: Secret.productID.rawValue,
                    googleMobileAds: {
                        sharedGoogleMobileAdsController.buildNativeAd($0)
                    },
                    licenseList: {
                        LicenseListView()
                    }
                )
                .task {
                    sharedGoogleMobileAdsController.start()
                }
        }
    }
}
