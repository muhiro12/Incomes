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
    @Environment(ItemService.self)
    private var itemService

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    @Query private var items: [Item]

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let title: String

    init(yearTag: Tag, descriptor: Item.FetchDescriptor) {
        title = yearTag.displayName
        _items = Query(descriptor)
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
            if !isSubscribeOn {
                AdvertisementSection(.medium)
            }
            ChartSections(items: items)
        }
        .actionSheet(isPresented: $isPresentedToAlert) {
            ActionSheet(title: Text("Are you sure you want to delete this item?"),
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
            ItemListYearSection(
                yearTag: preview.tags.first { $0.type == .year }!,
                descriptor: Item.descriptor(dateIsSameMonthAs: .now)
            )
        }
    }
}
