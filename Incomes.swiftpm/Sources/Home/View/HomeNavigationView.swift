//
//  HomeNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI
import SwiftUtilities

struct HomeNavigationView: View {
    @State private var path: IncomesPath?

    var body: some View {
        NavigationSplitView {
            HomeListView(selection: $path)
        } detail: {
            if case .itemList(let tag) = path {
                ItemListView()
                    .environment(tag)
            } else if case .year(let date) = path {
                YearChartsView(date: date)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        HomeNavigationView()
    }
}
