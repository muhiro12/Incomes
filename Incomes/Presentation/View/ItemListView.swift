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
    @Environment(\.modelContext)
    private var context

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @Query private var items: [Item]

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let title: String

    init(title: String, predicate: Predicate<Item>) {
        self.title = title
        _items = Query(filter: predicate, sort: Item.sortDescriptors())
    }
}

extension ItemListView: View {
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
                if !isSubscribeOn {
                    Advertisement(type: .native(.medium))
                }
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

private extension ItemListView {
    var sections: [SectionedItems<Date>] {
        ItemService.groupByYear(items: items)
    }
}

#Preview {
    ItemListView(title: "Title",
                 predicate: Item.predicate(dateIsSameMonthAs: Date()))
        .modelContainer(PreviewData.inMemoryContainer)
}
