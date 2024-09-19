//
//  OldMainTabView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

struct OldMainTabView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var tab: MainTab? = .home

    var body: some View {
        TabView(selection: $tab) {
            ForEach(MainTab.allCases) { tab in
                MainNavigationView(selection: $tab)
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

#Preview {
    IncomesPreview { _ in
        OldMainTabView()
    }
}
