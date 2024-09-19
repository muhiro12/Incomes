//
//  MainTabView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

@available(iOS 18.0, *)
struct MainTabView: View {
    var body: some View {
        TabView {
            ForEach(MainTab.allCases) { tab in
                Tab {
                    tab.rootView
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
