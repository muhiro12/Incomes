//
//  MainTabView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var mainTab = MainTab.home

    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                TabView(selection: $mainTab) {
                    ForEach(MainTab.allCases) { tab in
                        Tab(value: tab, role: tab == .search ? .search : nil) {
                            tab.rootView
                                .toolbar(
                                    horizontalSizeClass == .regular ? .visible : .hidden,
                                    for: .tabBar
                                )
                        } label: {
                            tab.label
                        }
                    }
                }
            } else {
                TabView(selection: $mainTab) {
                    ForEach(MainTab.allCases) { tab in
                        tab.rootView
                            .tag(tab)
                            .tabItem {
                                tab.label
                            }
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
            }
        }
        .environment(\.mainTab, $mainTab)
    }
}

#Preview {
    IncomesPreview { _ in
        MainTabView()
    }
}
