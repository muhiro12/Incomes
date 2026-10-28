#if DEBUG
//
//  DebugNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

struct DebugNavigationView: View {
    private let navigateToDestination: (SettingsNavigationDestination) -> Void

    var body: some View {
        DebugListView(navigateToRoute: navigate(to:))
    }

    init(
        navigateToDestination: @escaping (SettingsNavigationDestination) -> Void = { _ in
            // no-op
        }
    ) {
        self.navigateToDestination = navigateToDestination
    }
}

private extension DebugNavigationView {
    func navigate(to route: DebugRoute) {
        switch route {
        case .allTags:
            navigateToDestination(.debugAllTags)
        case .diagnostics:
            navigateToDestination(.debugDiagnostics)
        case .naturalLanguageSearch:
            navigateToDestination(.debugNaturalLanguageSearch)
        case .tag(let tagID):
            navigateToDestination(.debugTag(tagID))
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        DebugNavigationView()
    }
}
#endif
