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
    @Environment(\.modelContext)
    private var context

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
        _tags = Query(filter: Tag.predicate(contents: contents),
                      sort: Tag.sortDescriptors())
    }
}

extension CategorySection: View {
    var body: some View {
        Section(tag.name.isNotEmpty ? tag.name : "Others", isExpanded: $isExpanded) {
            ForEach(tags) {
                Text($0.name)
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
                            try ItemService(context: context).delete(items: willDeleteItems)
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
    ModelPreview { tag in
        ListPreview {
            CategorySection(categoryTag: tag)
        }
    }
}
