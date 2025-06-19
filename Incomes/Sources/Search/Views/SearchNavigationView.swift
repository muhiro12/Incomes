//
//  SearchNavigationView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SearchNavigationView: View {
    @State private var predicate: ItemPredicate?

    var body: some View {
        NavigationSplitView {
            SearchListView(selection: $predicate)
        } detail: {
            SearchResultView(predicate: predicate ?? .none)
        }
    }
}

#Preview {
    IncomesPreview { _ in
        SearchNavigationView()
    }
}
