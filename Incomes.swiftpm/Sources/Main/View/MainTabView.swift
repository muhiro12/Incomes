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

    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var tab: MainTab? = .home

    private var tabs: [MainTab] {
        if isDebugOn {
            MainTab.allCases
        } else {
            MainTab.allCases.filter {
                $0 != .debug
            }
        }
    }

    var body: some View {
        #if XCODE
        if #available(iOS 18.0, *) {
            TabView(selection: $tab) {
                ForEach(tabs) { tab in
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
                ForEach(tabs) { tab in
                    tab.rootView(selection: $tab)
                        .tag(tab as MainTab?)
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
        #else
        TabView(selection: $tab) {
            ForEach(tabs) { tab in
                tab.rootView(selection: $tab)
                    .tag(tab as MainTab?)
                    .tabItem {
                        tab.label
                    }
                    .toolbar(
                        horizontalSizeClass == .regular ? .visible : .hidden,
                        for: .tabBar
                    )
            }
        }
        #endif
    }
}

#Preview {
    IncomesPreview { _ in
        MainTabView()
    }
}
