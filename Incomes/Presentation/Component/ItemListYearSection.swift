//
//  ItemListYearSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/23.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct ItemListYearSection {
    @Environment(\.modelContext)
    private var context

    @Query private var items: [Item]

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let yearTag: Tag

    init(yearTag: Tag, predicate: Predicate<Item>) {
        self.yearTag = yearTag
        _items = Query(filter: predicate, sort: Item.sortDescriptors())
    }
}

extension ItemListYearSection: View {
    var body: some View {
        Section(content: {
            ForEach(items) {
                ListItem(of: $0)
            }
            .onDelete {
                willDeleteItems = $0.map { items[$0] }
                isPresentedToAlert = true
            }
        }, header: {
            Text(yearTag.name)
        })
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(title: Text(.localized(.deleteConfirm)),
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
        ListPreview {
            ItemListYearSection(yearTag: tag, predicate: .true)
        }
    }
}
