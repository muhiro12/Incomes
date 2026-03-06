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

                appRuntime.startIfNeeded()
                syncSubscriptionStateIfNeeded()
                try? await configurationService.load()
                isUpdateAlertPresented = configurationService.isUpdateRequired()
                await notificationService.update()
                applyPendingDeepLinkIfNeeded()
            }
            .onChange(of: scenePhase) {
                guard scenePhase == .active else {
                    return
                }
                appRuntime.startIfNeeded()
                syncSubscriptionStateIfNeeded()
                Task {
                    try? await configurationService.load()
                    isUpdateAlertPresented = configurationService.isUpdateRequired()
                }
                Task {
                    await notificationService.update()
                }
                Task {
                    _ = await IncomesApp.requestReviewIfNeeded(
                        policy: Self.reviewPolicy,
                        source: #fileID
                    )
                }
                applyPendingDeepLinkIfNeeded()
            }
            .onChange(of: appRuntime.premiumStatus) {
                syncSubscriptionStateIfNeeded()
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

    var routeLogger: MHLogger {
        IncomesApp.logger(
            category: "RouteExecution",
            source: #fileID
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
            routeLogger.info("ignored deep-link URL because parsing failed")
            return
        }
        routeLogger.info("accepted deep-link URL for route handling")
        incomingRoute = route
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    ContentView()
}
