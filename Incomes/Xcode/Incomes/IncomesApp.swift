//
//  IncomesApp.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Firebase
import GoogleMobileAdsWrapper
import IncomesPlaygrounds
import LicenseListWrapper
import StoreKitWrapper
import SwiftUI

@main
struct IncomesApp: App {
    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn

    private let sharedGoogleMobileAdsController: GoogleMobileAdsController
    private let sharedStore: Store

    init() {
        FirebaseApp.configure()

        sharedGoogleMobileAdsController = .init(
            adUnitID: {
                #if DEBUG
                Secret.admobNativeIDDev
                #else
                Secret.admobNativeID
                #endif
            }()
        )

        sharedStore = .init()

        IncomesShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .incomesEnvironment(
                    googleMobileAds: {
                        sharedGoogleMobileAdsController.buildNativeAd($0)
                    },
                    licenseList: {
                        LicenseListView()
                    },
                    storeKit: {
                        sharedStore.buildSubscriptionSection()
                    }
                )
                .task {
                    sharedGoogleMobileAdsController.start()

                    sharedStore.open(
                        groupID: Secret.groupID,
                        productIDs: [Secret.productID]
                    ) {
                        isSubscribeOn = $0.contains {
                            $0.id == Secret.productID
                        }
                        if !isSubscribeOn {
                            isICloudOn = false
                        }
                    }
                }
        }
    }
}
