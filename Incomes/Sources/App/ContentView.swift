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
    @Environment(IncomesRoutePipeline.self)
    private var routePipeline

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(\.isICloudOn)
    private var isICloudOn
    @AppStorage(\.isDebugOn)
    private var isDebugOn
}

extension ContentView: View {
    var body: some View {
        LedgerWorkspaceView()
            .safeAreaInset(edge: .top) {
                if remoteConfigurationService.scheduledUpdates.isEnabled {
                    RemoteUpdateStatusView(
                        decision: remoteConfigurationService.scheduledUpdates.decision,
                        isLoading: remoteConfigurationService.isLoading,
                        retry: retryUpdateCheck,
                        openStore: openAppStore
                    )
                }
            }
            .alert(
                "Invalid Link",
                isPresented: invalidDeepLinkAlertBinding,
                presenting: routePipeline.lastParseFailureURL
            ) { _ in
                Button("OK", role: .cancel) {
                    routePipeline.clearLastParseFailure()
                }
            } message: { invalidURL in
                Text("Incomes could not open \(invalidURL.absoluteString)")
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
    var invalidDeepLinkAlertBinding: Binding<Bool> {
        .init(
            get: {
                routePipeline.lastParseFailureURL != nil
            },
            set: { isPresented in
                if !isPresented {
                    routePipeline.clearLastParseFailure()
                }
            }
        )
    }

    func retryUpdateCheck() {
        Task {
            try? await remoteConfigurationService.load()
        }
    }

    func openAppStore() {
        if let appStoreURL = IncomesRemoteUpdateConfiguration.appStoreURL {
            UIApplication.shared.open(appStoreURL)
        }
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
            purchasedProductIDs = [
                IncomesMonetizationConfiguration.subscriptionProductID
            ]
        }

        let state = SubscriptionStateOperations.calculate(
            purchasedProductIDs: purchasedProductIDs,
            productID: IncomesMonetizationConfiguration.subscriptionProductID,
            isICloudOn: isICloudOn
        )
        isSubscribeOn = state.isSubscribeOn
        #if !DEBUG
        isICloudOn = state.isICloudOn
        #endif
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    ContentView()
}
