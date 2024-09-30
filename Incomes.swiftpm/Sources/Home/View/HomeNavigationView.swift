//
//  HomeNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI
import SwiftUtilities

struct HomeNavigationView: View {
    @Binding private var tab: MainTab?

    @State private var path: IncomesPath?

    init(selection: Binding<MainTab?> = .constant(nil)) {
        _tab = selection
    }

    var body: some View {
        NavigationSplitView {
            HomeListView(selection: $path)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        MainTabMenu(selection: $tab)
                    }
                }
        } detail: {
            if case .itemList(let tag) = path {
                ItemListView()
                    .environment(tag)
            } else if case .year(let date) = path {
                YearView(date: date)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        HomeNavigationView()
    }
}
