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

    @State private var isDialogPresented = false
    @State private var willDeleteItems: [Item] = []

    private let title: LocalizedStringKey?

    init(_ descriptor: FetchDescriptor<Item>, title: LocalizedStringKey? = nil) {
        self._items = Query(descriptor)
        self.title = title
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
                isDialogPresented = true
            }
        } header: {
            if let title {
                Text(title)
            }
        }
        .confirmationDialog(Text("Are you sure you want to delete this item?"), isPresented: $isDialogPresented) {
            Button(role: .destructive) {
                do {
                    try itemService.delete(items: willDeleteItems)
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                willDeleteItems = []
            } label: {
                Text("Cancel")
            }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        List {
            ItemListSection(.items(.dateIsSameYearAs(.now)))
        }
    }
}
