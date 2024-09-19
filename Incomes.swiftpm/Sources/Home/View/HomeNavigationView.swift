//
//  MainNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

struct HomeNavigationView: View {
    @State private var path: IncomesPath?

    var body: some View {
        NavigationSplitView {
            HomeListView(selection: $path)
        } detail: {
            path?.view
        }
    }
}

#Preview {
    IncomesPreview { _ in
        HomeNavigationView()
    }
}
