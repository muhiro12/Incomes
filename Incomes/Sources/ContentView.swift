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
    private struct NotificationPendingDeepLinkSource: MHDeepLinkURLSource, @unchecked Sendable {
        let notificationService: NotificationService

        func consumeLatestURL() async -> URL? {
            await notificationService.consumePendingDeepLinkURL()
        }
    }

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

    var runtimeLifecyclePlan: MHAppRuntimeLifecyclePlan {
        .init(
            startupTasks: [
                .init(name: "syncSubscriptionState") {
                    syncSubscriptionStateIfNeeded()
                },
                .init(name: "loadConfiguration") {
                    await refreshConfigurationState()
                },
                .init(name: "updateNotifications") {
                    await notificationService.update()
                },
                .init(name: "applyPendingDeepLink") {
                    await applyPendingDeepLinkIfNeeded()
                }
            ],
            activeTasks: [
                .init(name: "syncSubscriptionState") {
                    syncSubscriptionStateIfNeeded()
                },
                .init(name: "loadConfiguration") {
                    await refreshConfigurationState()
                },
                .init(name: "updateNotifications") {
                    await notificationService.update()
                },
                .init(name: "requestReview") {
                    await requestReviewIfNeeded()
                },
                .init(name: "applyPendingDeepLink") {
                    await applyPendingDeepLinkIfNeeded()
                }
            ],
            skipFirstActivePhase: true
        )
    }

    var pendingDeepLinkSources: [any MHDeepLinkURLSource] {
        var sources = [any MHDeepLinkURLSource]()

        if let intentRouteSource = IncomesIntentRouteStore.source {
            sources.append(intentRouteSource)
        }

        sources.append(
            NotificationPendingDeepLinkSource(
                notificationService: notificationService
            )
        )
        return sources
    }

    var reviewLogger: MHLogger {
        IncomesApp.logger(
            category: "ReviewFlow",
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

    @MainActor
    func refreshConfigurationState() async {
        try? await configurationService.load()
        isUpdateAlertPresented = configurationService.isUpdateRequired()
    }

    @MainActor
    func requestReviewIfNeeded() async {
        _ = await MHReviewRequester.requestIfNeeded(
            policy: Self.reviewPolicy,
            logger: reviewLogger
        )
    }

    func applyPendingDeepLinkIfNeeded() async {
        let sourceChain = MHDeepLinkSourceChain(pendingDeepLinkSources)
        guard let deepLinkURL = await sourceChain.consumeLatestURL() else {
            return
        }
        handleIncomingURL(deepLinkURL)
    }

    func handleIncomingURL(_ url: URL) {
        incomingRouteURL = url
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    ContentView()
}
