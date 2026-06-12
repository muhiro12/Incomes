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
    private enum DebugDetailRoot: Equatable {
        case placeholder
        case diagnostics
        case tagList
        case tag(Tag.ID)
    }

    @Environment(MHLoggingBootstrap.self)
    private var logging
    @Environment(\.modelContext)
    private var context
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    @State private var detailRoot: DebugDetailRoot = .placeholder
    @State private var detailTagPath: [Tag.ID] = []

    private let navigateToCompactDestination: (SettingsNavigationDestination) -> Void

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                DebugListView(
                    navigateToRoute: navigateToCompactRoute(to:)
                )
            } else {
                regularBody
            }
        }
    }

    init(
        navigateToCompactDestination: @escaping (SettingsNavigationDestination) -> Void = { _ in
            // no-op
        }
    ) {
        self.navigateToCompactDestination = navigateToCompactDestination
    }
}

private extension DebugNavigationView {
    var regularBody: some View {
        NavigationSplitView(preferredCompactColumn: preferredCompactColumnBinding) {
            DebugListView(
                navigateToRoute: navigateToRegularRoute(to:)
            )
        } detail: {
            NavigationStack(path: $detailTagPath) {
                detailView
                    .navigationDestination(for: Tag.ID.self) { tagID in
                        itemListView(for: tagID)
                    }
            }
        }
    }

    var detailView: some View {
        Group {
            switch detailRoot {
            case .placeholder:
                ContentUnavailableView(
                    "Select a Debug Target",
                    systemImage: "ladybug",
                    description: Text("Choose a debug destination from the sidebar to inspect its items.")
                )
            case .diagnostics:
                MHLogConsoleView(logging: logging)
                    .navigationTitle("Diagnostics Console")
            case .tagList:
                DebugTagListView(
                    selection: tagSelectionBinding
                )
                .navigationTitle("All Tags")
            case .tag(let tagID):
                itemListView(for: tagID)
            }
        }
        .toolbar {
            if horizontalSizeClass == .compact, detailRoot != .placeholder {
                ToolbarItem {
                    CloseButton()
                }
            }
        }
    }

    var preferredCompactColumnBinding: Binding<NavigationSplitViewColumn> {
        .init(
            get: {
                preferredCompactColumn
            },
            set: { preferredCompactColumn in
                self.preferredCompactColumn = preferredCompactColumn

                guard horizontalSizeClass == .compact,
                      preferredCompactColumn == .sidebar else {
                    return
                }

                detailRoot = .placeholder
                detailTagPath = []
            }
        )
    }

    var tagSelectionBinding: Binding<Tag.ID?> {
        .init(
            get: {
                detailTagPath.last
            },
            set: { tagID in
                guard let tagID else {
                    return
                }

                detailTagPath = [tagID]
            }
        )
    }

    func itemListView(
        for tagID: Tag.ID
    ) -> some View {
        Group {
            if let tag = tag(for: tagID) {
                ItemListGroup()
                    .environment(tag)
            } else {
                ContentUnavailableView(
                    "Unable to Load Debug Items",
                    systemImage: "exclamationmark.triangle",
                    description: Text("The selected tag could not be found.")
                )
            }
        }
    }

    func tag(for tagID: Tag.ID) -> Tag? {
        try? TagQueryOperations.getByPersistentID(
            context: context,
            persistentID: tagID
        )
    }

    func navigateToCompactRoute(to route: DebugRoute) {
        switch route {
        case .allTags:
            navigateToCompactDestination(.debugAllTags)
        case .diagnostics:
            navigateToCompactDestination(.debugDiagnostics)
        case .tag(let tagID):
            navigateToCompactDestination(.debugTag(tagID))
        }
    }

    func navigateToRegularRoute(to route: DebugRoute) {
        switch route {
        case .allTags:
            detailRoot = .tagList
            detailTagPath = []
        case .diagnostics:
            detailRoot = .diagnostics
            detailTagPath = []
        case .tag(let tagID):
            detailRoot = .tag(tagID)
            detailTagPath = []
        }

        if horizontalSizeClass == .compact {
            preferredCompactColumn = .detail
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    DebugNavigationView()
}
