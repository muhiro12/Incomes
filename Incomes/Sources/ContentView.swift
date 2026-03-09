//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//

import MHPlatform
import SwiftUI

struct ContentView {
    @Environment(RemoteConfigurationService.self)
    private var remoteConfigurationService
    @Environment(MHAppRuntime.self)
    private var appRuntime

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.isDebugOn)
    private var isDebugOn
}

extension ContentView: View {
    var body: some View {
        MainNavigationView()
            .alert("Update Required", isPresented: isUpdateRequiredBinding) {
                Button("Open App Store") {
                    if let appStoreURL = URL(
                        string: "https://apps.apple.com/jp/app/incomes/id1584472982"
                    ) {
                        UIApplication.shared.open(appStoreURL)
                    }
                }
            } message: {
                Text("Please update Incomes to the latest version to continue using it.")
            }
            .task {
                #if DEBUG
                isDebugOn = true
                #endif
                syncSubscriptionStateIfNeeded()
            }
            .onChange(of: appRuntime.premiumStatus) {
                syncSubscriptionStateIfNeeded()
            }
    }
}

private extension ContentView {
    var isUpdateRequiredBinding: Binding<Bool> {
        .init(
            get: {
                remoteConfigurationService.isUpdateRequired()
            },
            set: { _ in
                // Keep the alert driven by the latest remote configuration.
            }
        )
    }

    @MainActor
    func syncSubscriptionStateIfNeeded() {
        let purchasedProductIDs: Set<String>

        switch appRuntime.premiumStatus {
        case .unknown:
            return
        case .inactive:
            purchasedProductIDs = []
        case .active:
            purchasedProductIDs = [Secret.productID]
        }

        let state = SubscriptionStateCalculator.calculate(
            purchasedProductIDs: purchasedProductIDs,
            productID: Secret.productID,
            isICloudOn: isICloudOn
        )
        isSubscribeOn = state.isSubscribeOn
        isICloudOn = state.isICloudOn
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    ContentView()
}
