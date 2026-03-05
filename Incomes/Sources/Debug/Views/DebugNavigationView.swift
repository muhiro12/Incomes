//
//  DebugNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

struct DebugNavigationView: View {
    private enum DebugNavigationDestination: Hashable {
        case tagList
    }

    @State private var selectedTag: Tag?
    @State private var path: [DebugNavigationDestination] = []

    var body: some View {
        NavigationSplitView {
            NavigationStack(path: $path) {
                DebugListView(
                    navigateToRoute: navigate(to:)
                )
                .navigationDestination(
                    for: DebugNavigationDestination.self
                ) { destination in
                    switch destination {
                    case .tagList:
                        DebugTagListView(
                            navigateToRoute: navigate(to:)
                        )
                    }
                }
            }
        } detail: {
            if let selectedTag {
                ItemListGroup()
                    .environment(selectedTag)
            }
        }
    }

    private func navigate(to route: DebugRoute) {
        switch route {
        case .allTags:
            path = [.tagList]
        case .tag(let tag):
            selectedTag = tag
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    DebugNavigationView()
}
