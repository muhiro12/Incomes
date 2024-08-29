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
    private let descriptorBuilder: (Tag) -> Item.FetchDescriptor

    init(tag: Tag, descriptorBuilder: @escaping (Tag) -> Item.FetchDescriptor) {
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
        self.descriptorBuilder = descriptorBuilder
    }
}

extension ItemListView: View {
    var body: some View {
        List(yearTags) {
            ItemListYearSection(yearTag: $0,
                                descriptor: descriptorBuilder($0))
        }
        .listStyle(.grouped)
        .navigationTitle(Text(title))
        .toolbar {
            ToolbarItem {
                CreateButton()
            }
            ToolbarItem(placement: .status) {
                Text("\(yearTags.flatMap { $0.items.orEmpty }.count) Items")
                    .font(.footnote)
            }
        }
    }
}

#Preview {
    IncomesPreview { preview in
        ItemListView(
            tag: preview.tags.first { $0.name == Date.now.stringValueWithoutLocale(.yyyy) }!
        ) { _ in
            Item.descriptor(dateIsSameMonthAs: .now)
        }
    }
}
