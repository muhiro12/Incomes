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
}

extension CategoryView: View {
    var body: some View {
        List {
            ForEach(tags) {
                CategorySection(title: $0.name.isNotEmpty ? $0.name : .localized(.others),
                                items: $0.items ?? [])
            }
        }
        .id(UUID())
        .listStyle(.sidebar)
        .navigationBarTitle(.localized(.categoryTitle))
    }
}

#Preview {
    ModelsPreview { (_: [Tag]) in
        CategoryView()
    }
}
