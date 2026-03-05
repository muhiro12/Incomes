//
//  SettingsNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

struct SettingsNavigationView: View {
    @Binding private var incomingDestination: SettingsNavigationDestination?

    @State private var path: [SettingsNavigationDestination] = []

    private let navigateToRoute: (IncomesRoute) -> Void

    var body: some View {
        NavigationStack(path: $path) {
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

    init(
        incomingDestination: Binding<SettingsNavigationDestination?> = .constant(nil),
        navigateToRoute: @escaping (IncomesRoute) -> Void = { _ in
            // no-op
        }
    ) {
        _incomingDestination = incomingDestination
        self.navigateToRoute = navigateToRoute
    }
}

private extension SettingsNavigationView {
    func applyIncomingDestinationIfNeeded() {
        guard let incomingDestination else {
            return
        }
        path = [incomingDestination]
        self.incomingDestination = nil
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    SettingsNavigationView()
}
