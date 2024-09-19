//
//  MainNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI
import SwiftUtilities

struct MainNavigationView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var tab = MainTab.home
    @State private var path: IncomesPath?

    var body: some View {
        NavigationSplitView {
            Group {
                switch tab {
                case .home:
                    HomeListView(selection: $path)
                case .category:
                    CategoryListView(selection: $path)
                case .settings:
                    SettingsView()
                case .debug:
                    DebugListView()
                }
            }
            .toolbar {
                if horizontalSizeClass == .compact {
                    ToolbarItem(placement: .bottomBar) {
                        Menu {
                            ForEach(MainTab.allCases) { tab in
                                Button {
                                    withAnimation {
                                        self.tab = tab
                                    }
                                } label: {
                                    tab.label
                                }
                            }
                        } label: {
                            Label {
                                Text("Menu")
                            } icon: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                }
            }
        } detail: {
            path?.view
        }
    }
}

#Preview {
    IncomesPreview { _ in
        MainNavigationView()
    }
}
