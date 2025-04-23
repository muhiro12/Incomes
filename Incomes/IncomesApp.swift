//
//  IncomesApp.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import GoogleMobileAdsWrapper
import StoreKitWrapper
import SwiftUI

@main
struct IncomesApp: App {
    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.isDebugOn)
    private var isDebugOn

    private let sharedStore: Store
    private let sharedGoogleMobileAdsController: GoogleMobileAdsController

    init() {
        sharedStore = .init()

        sharedGoogleMobileAdsController = .init(
            adUnitID: {
                #if DEBUG
                Secret.admobNativeIDDev
                #else
                Secret.admobNativeID
                #endif
            }()
        )

        #if DEBUG
        isDebugOn = true
        #endif

        IncomesShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sharedStore)
                .environment(\.googleMobileAdsController, sharedGoogleMobileAdsController)
                .task {
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

                    sharedGoogleMobileAdsController.start()
                }
        }
    }
}
