//
//  DebugNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import MHPlatform
import SwiftData
import SwiftUI

struct DebugNavigationView: View {
    private enum DebugNavigationDestination: Hashable {
        case diagnostics
        case tagList
    }

    @Environment(MHLoggingBootstrap.self)
    private var logging
    @Environment(\.modelContext)
    private var context
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    @State private var selectedTagID: Tag.ID?
    @State private var path: [DebugNavigationDestination] = []

    var body: some View {
        NavigationSplitView(preferredCompactColumn: preferredCompactColumnBinding) {
            NavigationStack(path: $path) {
                DebugListView(
                    navigateToRoute: navigate(to:)
                )
                .navigationDestination(
                    for: DebugNavigationDestination.self
                ) { destination in
                    switch destination {
                    case .diagnostics:
                        MHLogConsoleView(logging: logging)
                    case .tagList:
                        DebugTagListView(
                            selection: selectedTagIDBinding
                        )
                    }
                }
            }
        } detail: {
            if let selectedTag {
                ItemListGroup()
                    .environment(selectedTag)
            } else {
                ContentUnavailableView(
                    "Select a Debug Target",
                    systemImage: "ladybug",
                    description: Text("Choose a debug destination from the sidebar to inspect its items.")
                )
            }
        }
    }
}

private extension DebugNavigationView {
    var selectedTag: Tag? {
        guard let selectedTagID else {
            return nil
        }
        return try? context.fetchFirst(.tags(.idIs(selectedTagID)))
    }

    var preferredCompactColumnBinding: Binding<NavigationSplitViewColumn> {
        .init(
            get: {
                preferredCompactColumn
            },
            set: { preferredCompactColumn in
                self.preferredCompactColumn = preferredCompactColumn

                guard horizontalSizeClass == .compact else {
                    return
                }

                if preferredCompactColumn == .sidebar {
                    selectedTagID = nil
                }
            }
        )
    }

    var selectedTagIDBinding: Binding<Tag.ID?> {
        .init(
            get: {
                selectedTagID
            },
            set: { selectedTagID in
                self.selectedTagID = selectedTagID
                if selectedTagID != nil {
                    preferredCompactColumn = .detail
                }
            }
        )
    }

    func navigate(to route: DebugRoute) {
        switch route {
        case .allTags:
            selectedTagID = nil
            path = [.tagList]
        case .diagnostics:
            path = [.diagnostics]
        case .tag(let tagID):
            selectedTagID = tagID
            preferredCompactColumn = .detail
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    DebugNavigationView()
}
