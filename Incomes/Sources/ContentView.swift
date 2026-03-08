//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//

import MHPlatform
import SwiftUI

struct ContentView {
    @Environment(NotificationService.self)
    private var notificationService
    @Environment(ConfigurationService.self)
    private var configurationService
    @Environment(MHAppRuntime.self)
    private var appRuntime

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var isUpdateAlertPresented = false
    @State private var incomingRouteURL: URL?
}

extension ContentView: View {
    var body: some View {
        MainNavigationView(incomingRouteURL: $incomingRouteURL)
            .alert("Update Required", isPresented: $isUpdateAlertPresented) {
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
            .mhAppRuntimeLifecycle(
                runtime: appRuntime,
                plan: runtimeLifecyclePlan
            )
            .task {
                #if DEBUG
                isDebugOn = true
                #endif
            }
            .onChange(of: appRuntime.premiumStatus) {
                syncSubscriptionStateIfNeeded()
            }
            .onChange(of: notificationService.pendingDeepLinkURL) {
                Task {
                    await applyPendingDeepLinkIfNeeded()
                }
            }
            .onOpenURL { url in
                handleIncomingURL(url)
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                guard let webpageURL = userActivity.webpageURL else {
                    return
                }
                handleIncomingURL(webpageURL)
            }
    }
}

private extension ContentView {
    var runtimeLifecyclePlan: MHAppRuntimeLifecyclePlan {
        IncomesRuntimeLifecycleSupport.makePlan(
            syncSubscriptionStateIfNeeded: {
                syncSubscriptionStateIfNeeded()
            },
            refreshConfigurationState: {
                await refreshConfigurationState()
            },
            updateNotifications: {
                await notificationService.update()
            },
            requestReviewIfNeeded: {
                await requestReviewIfNeeded()
            },
            applyPendingDeepLinkIfNeeded: {
                await applyPendingDeepLinkIfNeeded()
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

    @MainActor
    func refreshConfigurationState() async {
        try? await configurationService.load()
        isUpdateAlertPresented = configurationService.isUpdateRequired()
    }

    @MainActor
    func requestReviewIfNeeded() async {
        _ = await IncomesReviewSupport.requestIfNeeded(
            context: .appActivation,
            source: #fileID
        )
    }

    func applyPendingDeepLinkIfNeeded() async {
        guard let deepLinkURL = await IncomesPendingDeepLinkSupport.consumeLatestURL(
            notificationService: notificationService
        ) else {
            return
        }
        handleIncomingURL(deepLinkURL)
    }

    func handleIncomingURL(_ url: URL) {
        incomingRouteURL = url
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    ContentView()
}
