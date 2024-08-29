//
//  CategorySection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct CategorySection {
    @Environment(ItemService.self)
    private var itemService

    @Query private var tags: [Tag]

    @State private var isExpanded = true
    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let tag: Tag

    init(categoryTag: Tag) {
        tag = categoryTag

        let contents = Array(
            Set(
                categoryTag.items?.map {
                    $0.content
                } ?? []
            )
        )
        _tags = Query(Tag.descriptor(contents: contents))
    }
}

extension CategorySection: View {
    var body: some View {
        Section(tag.name.isNotEmpty ? tag.name : "Others", isExpanded: $isExpanded) {
            ForEach(tags) { tag in
                if tag.items.orEmpty.isNotEmpty {
                    NavigationLink(path: .itemList(tag)) {
                        Text(tag.name)
                    }
                }
            }.onDelete {
                isPresentedToAlert = true
                willDeleteItems = $0.flatMap { tags[$0].items ?? [] }
            }
        }
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(
                title: Text("Are you sure you want to delete this item?"),
                buttons: [
                    .destructive(Text("Delete")) {
                        do {
                            try itemService.delete(items: willDeleteItems)
                        } catch {
                            assertionFailure(error.localizedDescription)
                        }
                    },
                    .cancel {
                        willDeleteItems = []
                    }
                ])
        }
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            CategorySection(
                categoryTag: preview.tags.first { $0.type == .category }!
            )
        }
    }
}
