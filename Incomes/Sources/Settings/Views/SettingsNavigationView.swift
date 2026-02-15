//
//  SettingsNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

enum SettingsNavigationDestination: Hashable {
    case subscription
    case license
    case debug
}

struct SettingsNavigationView: View {
    @Binding private var incomingDestination: SettingsNavigationDestination?

    @StateObject private var router: SettingsNavigationRouter = .init()

    private let navigateToRoute: (IncomesRoute) -> Void

    init(
        incomingDestination: Binding<SettingsNavigationDestination?> = .constant(nil),
        navigateToRoute: @escaping (IncomesRoute) -> Void = { _ in
        }
    ) {
        _incomingDestination = incomingDestination
        self.navigateToRoute = navigateToRoute
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            SettingsListView(
                navigateToRoute: navigateToRoute
            )
            .navigationDestination(for: SettingsNavigationDestination.self) { destination in
                switch destination {
                case .subscription:
                    StoreListView()
                case .license:
                    LicenseView()
                case .debug:
                    DebugNavigationView()
                }
            }
        }
        .task {
            applyIncomingDestinationIfNeeded()
        }
        .onChange(of: incomingDestination) {
            applyIncomingDestinationIfNeeded()
        }
    }
}

private extension SettingsNavigationView {
    func applyIncomingDestinationIfNeeded() {
        guard router.applyIncomingDestination(incomingDestination) else {
            return
        }
        self.incomingDestination = nil
    }
}

@MainActor
private final class SettingsNavigationRouter: ObservableObject {
    @Published var path: [SettingsNavigationDestination] = []

    func applyIncomingDestination(
        _ incomingDestination: SettingsNavigationDestination?
    ) -> Bool {
        guard let incomingDestination else {
            return false
        }
        path = [incomingDestination]
        return true
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    SettingsNavigationView()
}
