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
                case .root:
                    EmptyView()
                case .subscription:
                    StoreListView()
                case .license:
                    LicenseView()
                case .debug:
                    DebugNavigationView(
                        navigateToCompactDestination: navigateToDestination
                    )
                case .debugDiagnostics:
                    DebugDiagnosticsView()
                case .debugAllTags:
                    DebugAllTagsView(
                        selection: debugTagSelectionBinding
                    )
                case .debugTag(let tagID):
                    DebugTagItemListView(tagID: tagID)
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
    var debugTagSelectionBinding: Binding<Tag.ID?> {
        .init(
            get: {
                guard case .debugTag(let tagID) = path.last else {
                    return nil
                }
                return tagID
            },
            set: { tagID in
                guard let tagID else {
                    return
                }
                path.append(.debugTag(tagID))
            }
        )
    }

    func applyIncomingDestinationIfNeeded() {
        guard let incomingDestination else {
            return
        }
        path = navigationPath(for: incomingDestination)
        self.incomingDestination = nil
    }

    func navigateToDestination(
        _ destination: SettingsNavigationDestination
    ) {
        path.append(destination)
    }

    func navigationPath(
        for destination: SettingsNavigationDestination
    ) -> [SettingsNavigationDestination] {
        switch destination {
        case .root:
            []
        case .subscription,
             .license,
             .debug:
            [destination]
        case .debugDiagnostics,
             .debugAllTags,
             .debugTag:
            [.debug, destination]
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    SettingsNavigationView()
}
