//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import GoogleMobileAdsWrapper
import StoreKitWrapper
import SwiftUI

struct ContentView {
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(ConfigurationService.self)
    private var configurationService
    @Environment(Store.self)
    private var store
    @Environment(GoogleMobileAdsController.self)
    private var googleMobileAdsController

    @Environment(\.scenePhase)
    private var scenePhase
    @Environment(\.requestReview)
    private var requestReview

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var isUpdateAlertPresented = false
}

extension ContentView: View {
    var body: some View {
        MainNavigationView()
            .alert("Update Required", isPresented: $isUpdateAlertPresented) {
                Button("Open App Store") {
                    UIApplication.shared.open(
                        .init(string: "https://apps.apple.com/jp/app/incomes/id1584472982")!
                    )
                }
            } message: {
                Text("Please update Incomes to the latest version to continue using it.")
            }
            .task {
                #if DEBUG
                isDebugOn = true
                #endif

                try? await configurationService.load()
                isUpdateAlertPresented = configurationService.isUpdateRequired()

                store.open(
                    groupID: nil,
                    productIDs: [Secret.productID]
                ) { products in
                    let purchasedProductIDs = Set(products.map(\.id))
                    let state = SubscriptionStateCalculator.calculate(
                        purchasedProductIDs: purchasedProductIDs,
                        productID: Secret.productID,
                        isICloudOn: isICloudOn
                    )
                    isSubscribeOn = state.isSubscribeOn
                    isICloudOn = state.isICloudOn
                }

                googleMobileAdsController.start()
            }
            .onChange(of: scenePhase) {
                guard scenePhase == .active else {
                    return
                }
                Task {
                    try? await configurationService.load()
                    isUpdateAlertPresented = configurationService.isUpdateRequired()
                }
                Task {
                    await notificationService.update()
                }
                if ReviewRequestPolicy.shouldRequestReview(
                    randomValue: Int.random(in: 0..<10),
                    maxExclusive: 10
                ) {
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        requestReview()
                    }
                }
            }
    }
}

#Preview {
    IncomesPreview { _ in
        ContentView()
    }
}
