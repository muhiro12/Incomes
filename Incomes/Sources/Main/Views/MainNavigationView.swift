//
//  MainNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

struct MainNavigationView: View {
    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var tag: Tag?
    @State private var searchText = ""
    @State private var predicate: ItemPredicate?
    @State private var isSearchPresented = false
    @State private var isSettingsPresented = false
    @State private var isDebugPresented = false

    var body: some View {
        NavigationSplitView {
            Group {
                if isSearchPresented {
                    SearchListView(selection: $predicate)
                } else {
                    HomeListView(selection: $tag)
                }
            }
            .toolbar {
                if isDebugOn {
                    ToolbarItem {
                        Button("Debug", systemImage: "flask") {
                            isDebugPresented = true
                        }
                    }
                }
                ToolbarItem {
                    Button("Settings", systemImage: "gear") {
                        isSettingsPresented = true
                    }
                }
            }
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .largeSubtitle) {
                        Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    ToolbarItem(placement: .status) {
                        Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                            .font(.footnote)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    if isSearchPresented {
                        Button("Close", systemImage: "xmark") {
                            isSearchPresented = false
                        }
                    } else {
                        Button("Search", systemImage: "magnifyingglass") {
                            isSearchPresented = true
                        }
                    }
                }
                if #available(iOS 26.0, *) {
                    ToolbarSpacer(placement: .bottomBar)
                }
                ToolbarItem(placement: .bottomBar) {
                    CreateItemButton()
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsNavigationView()
            }
            .sheet(isPresented: $isDebugPresented) {
                DebugNavigationView()
            }
        } detail: {
            if isSearchPresented {
                SearchResultView(predicate: predicate ?? .none)
            } else if let tag {
                ItemListGroup()
                    .environment(tag)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        MainNavigationView()
    }
}
