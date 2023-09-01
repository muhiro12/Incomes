//
//  ItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct ItemListView: View {
    @Environment(\.modelContext)
    private var context

    @Query private var items: [Item]
    private var sections: [SectionedItems<Date>] {
        ItemService.groupByYear(items: items)
    }

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let title: String

    init(title: String, predicate: Predicate<Item>) {
        self.title = title
        _items = Query(filter: predicate, sort: Item.sortDescriptors())
    }

    var body: some View {
        List {
            ForEach(sections) { section in
                Section(content: {
                    ForEach(section.items) {
                        ListItem(of: $0)
                    }
                    .onDelete {
                        willDeleteItems = $0.map { section.items[$0] }
                        isPresentedToAlert = true
                    }
                }, header: {
                    if sections.count > .one {
                        Text(section.section.stringValue(.yyyy))
                    }
                })
                Advertisement(type: .native(.medium))
            }
        }
        .id(UUID())
        .navigationBarTitle(title)
        .listStyle(.grouped)
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
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        ItemListView(title: "Title",
                     predicate: Item.predicate(dateIsSameMonthAs: Date()))
    }
}
