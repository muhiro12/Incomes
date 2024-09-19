//
//  MainTabView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

@available(iOS 18.0, *)
struct MainTabView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var tab: MainTab? = .home

    var body: some View {
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
    }
}

@available(iOS 18.0, *)
#Preview {
    IncomesPreview { _ in
        MainTabView()
    }
}
