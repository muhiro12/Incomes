//
//  CategoryNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

struct CategoryNavigationView: View {
    @State private var path: IncomesPath?

    var body: some View {
        NavigationSplitView {
            CategoryListView(selection: $path)
        } detail: {
            path?.view
        }
    }
}

#Preview {
    IncomesPreview { _ in
        CategoryNavigationView()
    }
}
