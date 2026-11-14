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
            .onChange(of: appRuntime.premiumStatus, initial: true) {
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
        let access: SubscriptionStateOperations.SubscriptionAccess

        switch appRuntime.premiumStatus {
        case .unknown:
            access = .unknown
        case .inactive:
            access = .inactive
        case .active:
            access = .active
        }

        SubscriptionStateOperations.updateSubscriptionAccess(
            access,
            store: appRuntime.preferenceStore
        )
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    ContentView()
}
