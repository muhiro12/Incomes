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
        Section(content: {
            ForEach(tags) {
                Text($0.name)
            }.onDelete {
                isPresentedToAlert = true
                willDeleteItems = $0.flatMap { tags[$0].items ?? [] }
            }
        }, header: {
            Text(tag.name.isNotEmpty ? tag.name : .localized(.others))
        })
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(
                title: Text(.localized(.deleteConfirm)),
                buttons: [
                    .destructive(Text(.localized(.delete))) {
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
        List {
            CategorySection(categoryTag: tag)
        }
    }
}
