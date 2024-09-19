//
//  MainNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

struct HomeNavigationView: View {
    @State private var detail: IncomesPath?

    var body: some View {
        NavigationSplitView {
            HomeView()
                .environment(\.pathSelection, $detail)
        } detail: {
            detail?.view
        }
    }
}

#Preview {
    IncomesPreview { _ in
        HomeNavigationView()
    }
}
