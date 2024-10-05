//
//  CategoryListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct CategoryListView {
    @Query(.tags(.typeIs(.category)))
    private var tags: [Tag]

    @Binding private var path: IncomesPath?

    init(selection: Binding<IncomesPath?> = .constant(nil)) {
        _path = selection
    }
}

extension CategoryListView: View {
    var body: some View {
        List(tags, selection: $path) { tag in
            if tag.items.isNotEmpty {
                CategorySection(categoryTag: tag)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(Text("Category"))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                MainTabMenu()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
            ToolbarItem(placement: .bottomBar) {
                CreateButton()
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        CategoryListView()
    }
}
