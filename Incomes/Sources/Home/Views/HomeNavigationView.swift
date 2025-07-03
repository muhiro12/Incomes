//
//  HomeNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

struct HomeNavigationView: View {
    @State private var path: IncomesPath?

    var body: some View {
        NavigationSplitView {
            HomeListView(selection: $path)
        } detail: {
            if case .itemList(let tagEntity) = path {
                ItemListView()
                    .environment(tagEntity)
            } else if case .year(let yearTagEntity) = path {
                YearChartsView()
                    .environment(yearTagEntity)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        HomeNavigationView()
    }
}
