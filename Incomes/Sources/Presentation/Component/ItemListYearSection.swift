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

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @Query private var items: [Item]

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let title: String

    init(yearTag: Tag, predicate: Predicate<Item>) {
        title = yearTag.displayName
        _items = Query(filter: predicate, sort: Item.sortDescriptors())
    }
}

extension ItemListYearSection: View {
    var body: some View {
        Group {
            Section(content: {
                ForEach(items) {
                    ListItem(of: $0)
                }
                .onDelete {
                    willDeleteItems = $0.map { items[$0] }
                    isPresentedToAlert = true
                }
            }, header: {
                Text(title)
            })
            if isSubscribeOn {
                ChartSections(items: items)
            } else {
                Section {
                    Advertisement(.medium)
                }
            }
        }
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(title: Text("Are you sure you want to delete this item?"),
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
    ItemListYearSection(
        yearTag: PreviewData.tags.filter {
            $0.type == .year
        }[0],
        predicate: Item.predicate(dateIsSameMonthAs: .now)
    )
    .previewList()
    .previewContext()
}
