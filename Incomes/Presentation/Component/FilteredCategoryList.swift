//
//  FilteredCategoryList.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/26.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct FilteredCategoryList {
    @Query(filter: Tag.predicate(type: .category), sort: Tag.sortDescriptors())
    private var tags: [Tag]

    @Binding private var category: String

    init(category: Binding<String>) {
        _category = category
    }
}

extension FilteredCategoryList: View {
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(tags.filter {
                    $0.name.lowercased()
                        .contains(category.lowercased())
                        || category.isEmpty
                }) { tag in
                    Button(tag.name) {
                        category = tag.name
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                }
            }
        }
    }
}

#Preview {
    ModelPreview { (_: Tag) in
        FilteredCategoryList(category: .constant(.empty))
    }
}
