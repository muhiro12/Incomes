//
//  ItemListSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/6/24.
//

import SwiftData
import SwiftUI

struct ItemListSection {
    @Environment(ItemService.self)
    private var itemService

    @Query private var items: [Item]

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let title: String

    init(title: String, descriptor: FetchDescriptor<Item>) {
        self.title = title
        self._items = Query(descriptor)
    }
}

extension ItemListSection: View {
    var body: some View {
        Section {
            ForEach(items) {
                ListItem()
                    .environment($0)
            }
            .onDelete {
                willDeleteItems = $0.map { items[$0] }
                isPresentedToAlert = true
            }
        } header: {
            Text(title)
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
                ]
            )
        }
    }
}

#Preview {
    IncomesPreview { _ in
        List {
            ItemListSection(
                title: "Title",
                descriptor: Item.descriptor(.dateIsSameMonthAs(.now))
            )
        }
    }
}
