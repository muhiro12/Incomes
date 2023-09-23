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

    @Binding private var contentID: Tag.ID?

    init(contentID: Binding<Tag.ID?>) {
        _contentID = contentID
    }
}

extension CategoryView: View {
    var body: some View {
        List(selection: $contentID) {
            ForEach(tags) {
                CategorySection(categoryTag: $0)
            }
        }
        .navigationBarTitle(.localized(.categoryTitle))
    }
}

#Preview {
    ModelsPreview { (_: [Tag]) in
        CategoryView(contentID: .constant(nil))
    }
}
