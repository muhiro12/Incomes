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
    @Query(Tag.descriptor(type: .category))
    private var tags: [Tag]

    @Binding private var selection: Tag?

    init(selection: Binding<Tag?>) {
        _selection = selection
    }
}

extension CategoryView: View {
    var body: some View {
        List(tags, selection: $selection) { tag in
            if tag.items.orEmpty.isNotEmpty {
                CategorySection(categoryTag: tag)
            }
        }
        .navigationTitle(Text("Category"))
        .listStyle(.sidebar)
    }
}

#Preview {
    IncomesPreview { _ in
        CategoryView(selection: .constant(nil))
    }
}
