//
//  ItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct ItemListView {
    private let title: String
    private let yearTags: [Tag]
    private let predicateBuilder: (Tag) -> Predicate<Item>

    init(tag: Tag, predicateBuilder: @escaping (Tag) -> Predicate<Item>) {
        self.title = tag.displayName
        self.yearTags = Set(
            tag.items?.compactMap {
                $0.tags?.first {
                    $0.type == .year
                }
            } ?? []
        ).sorted {
            $0.name > $1.name
        }
        self.predicateBuilder = predicateBuilder
    }
}

extension ItemListView: View {
    var body: some View {
        List(yearTags) {
            ItemListYearSection(yearTag: $0,
                                predicate: predicateBuilder($0))
        }
        .navigationBarTitle(title)
    }
}

#Preview {
    ModelPreview { tag in
        NavigationStackPreview {
            ItemListView(tag: tag) { _ in .true }
        }
    }
}
