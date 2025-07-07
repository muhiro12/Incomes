//
//  HomeNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

struct HomeNavigationView: View {
    @State private var tag: TagEntity?

    var body: some View {
        NavigationSplitView {
            HomeListView(selection: $tag)
        } detail: {
            if let tag {
                ItemListGroup()
                    .environment(tag)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        HomeNavigationView()
    }
}
