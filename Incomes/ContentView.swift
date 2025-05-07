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
    @Environment(TagService.self)
    private var tagService
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
        MainTabView()
            .alert(Text("Update Required"), isPresented: $isUpdateAlertPresented) {
                Button {
                    UIApplication.shared.open(
                        .init(string: "https://apps.apple.com/jp/app/incomes/id1584472982")!
                    )
                } label: {
                    Text("Open App Store")
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
                    try? tagService.updateHasDuplicates()
                    await notificationService.update()
                }
                if Int.random(in: 0..<10) == .zero {
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
