//
//  DebugNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

struct DebugNavigationView: View {
    @StateObject private var router: DebugNavigationRouter = .init()

    var body: some View {
        NavigationSplitView {
            NavigationStack(path: $router.path) {
                DebugListView(
                    navigateToRoute: router.navigate(to:)
                )
                .navigationDestination(
                    for: DebugNavigationDestination.self
                ) { destination in
                    switch destination {
                    case .tagList:
                        DebugTagListView(
                            navigateToRoute: router.navigate(to:)
                        )
                    }
                }
            }
        } detail: {
            if let selectedTag = router.selectedTag {
                ItemListGroup()
                    .environment(selectedTag)
            }
        }
    }
}

private enum DebugNavigationDestination: Hashable {
    case tagList
}

@MainActor
private final class DebugNavigationRouter: ObservableObject {
    @Published var selectedTag: Tag?
    @Published var path: [DebugNavigationDestination] = []

    func navigate(to route: DebugRoute) {
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
