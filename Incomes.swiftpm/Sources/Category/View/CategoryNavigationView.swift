//
//  CategoryNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI
import SwiftUtilities

struct CategoryNavigationView: View {
    @State private var path: IncomesPath?

    var body: some View {
        NavigationSplitView {
            CategoryListView(selection: $path)
        } detail: {
            if case .itemList(let tag) = path {
                ItemListView()
                    .environment(tag)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        CategoryNavigationView()
    }
}
