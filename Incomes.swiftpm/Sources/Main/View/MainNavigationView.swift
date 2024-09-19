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

    @State private var tab: MainTab
    @State private var path: IncomesPath?

    init(tab: MainTab) {
        self.tab = tab
    }

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
                                Image(systemName: "list.bullet")
                            }
                        }
                    }
                }
            }
        } detail: {
            switch path {
            case .year(let date):
                YearView(date: date)
            case .itemForm(let mode):
                ItemFormView(mode: mode)
            case .itemList(let tag):
                ItemListView()
                    .environment(tag)
            case .tag(let tag):
                TagView()
                    .environment(tag)
            case .none:
                EmptyView()
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        MainNavigationView(tab: .home)
    }
}
