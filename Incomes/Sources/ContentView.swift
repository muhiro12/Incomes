//
//  ContentView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/08.
//

import GoogleMobileAdsWrapper
import MHPlatform
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

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var isUpdateAlertPresented = false
    @State private var incomingRoute: IncomesRoute?
}

extension ContentView: View {
    var body: some View {
        MainNavigationView(incomingRoute: $incomingRoute)
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
                await notificationService.update()
                applyPendingDeepLinkIfNeeded()
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
                Task {
                    _ = await MHReviewRequester.requestIfNeeded(
                        policy: Self.reviewPolicy
                    )
                }
                applyPendingDeepLinkIfNeeded()
            }
            .onChange(of: notificationService.pendingDeepLinkURL) {
                applyPendingDeepLinkIfNeeded()
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
    private enum ReviewConstants {
        static let lotteryMaxExclusive = 10
        static let requestDelaySeconds = 2
    }

    static var reviewPolicy: MHReviewPolicy {
        .init(
            lotteryMaxExclusive: ReviewConstants.lotteryMaxExclusive,
            requestDelay: .seconds(ReviewConstants.requestDelaySeconds)
        )
    }

    func applyPendingDeepLinkIfNeeded() {
        if let intentDeepLinkURL = IncomesIntentRouteStore.consume() {
            handleIncomingURL(intentDeepLinkURL)
        }
        if let notificationDeepLinkURL = notificationService.consumePendingDeepLinkURL() {
            handleIncomingURL(notificationDeepLinkURL)
        }
    }

    func handleIncomingURL(_ url: URL) {
        guard let route = IncomesRouteParser.parse(url: url) else {
            return
        }
        incomingRoute = route
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    ContentView()
}
