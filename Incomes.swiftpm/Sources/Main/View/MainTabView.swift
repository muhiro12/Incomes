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

    @State private var mainTab = MainTab.home

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
        TabView(selection: $mainTab) {
            ForEach(tabs) { tab in
                Tab(value: tab) {
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
        .environment(\.mainTab, $mainTab)
    }
}

#Preview {
    IncomesPreview { _ in
        MainTabView()
    }
}
