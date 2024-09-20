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

    @State private var tab: MainTab? = .home

    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $tab) {
                ForEach(MainTab.allCases) { tab in
                    Tab(value: tab) {
                        tab.rootView(selection: $tab)
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
            TabView(selection: $tab) {
                ForEach(MainTab.allCases) { tab in
                    tab.rootView(selection: $tab)
                        .tag(tab)
                        .tabItem {
                            tab.label
                        }
                        .toolbar(
                            horizontalSizeClass == .regular ? .visible : .hidden,
                            for: .tabBar
                        )
                }
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        MainTabView()
    }
}
