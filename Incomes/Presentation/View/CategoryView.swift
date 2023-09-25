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
    @Query(filter: Tag.predicate(type: .category), sort: Tag.sortDescriptors())
    private var tags: [Tag]

    @Binding private var selection: Tag.ID?

    init(selection: Binding<Tag.ID?>) {
        _selection = selection
    }
}

extension CategoryView: View {
    var body: some View {
        List(tags, selection: $selection) {
            CategorySection(categoryTag: $0)
        }
        .navigationBarTitle(.localized(.categoryTitle))
        .listStyle(.sidebar)
    }
}

#Preview {
    ModelsPreview { (_: [Tag]) in
        NavigationStackPreview {
            CategoryView(selection: .constant(nil))
        }
    }
}
