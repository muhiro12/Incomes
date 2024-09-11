//
//  CategoryView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct CategoryView {
    @Query(Tag.descriptor(.typeIs(.category)))
    private var tags: [Tag]

    @Environment(\.pathSelection) private var selection
}

extension CategoryView: View {
    var body: some View {
        List(tags, selection: selection) { tag in
            if tag.items.orEmpty.isNotEmpty {
                CategorySection(categoryTag: tag)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(Text("Category"))
        .toolbar {
            ToolbarItem {
                CreateButton()
            }
            ToolbarItem(placement: .status) {
                Text("Today: \(Date.now.stringValue(.yyyyMMMd))")
                    .font(.footnote)
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        CategoryView()
    }
}
