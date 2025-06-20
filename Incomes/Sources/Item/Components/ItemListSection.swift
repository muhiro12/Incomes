//
//  ItemListSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/6/24.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct ItemListSection: View {
    @Environment(\.modelContext)
    private var context

    @BridgeQuery private var items: [ItemEntity]

    @State private var isDialogPresented = false
    @State private var willDeleteItems: [ItemEntity] = []

    private let title: LocalizedStringKey?

    init(_ descriptor: FetchDescriptor<Item>, title: LocalizedStringKey? = nil) {
        self._items = BridgeQuery(Query(descriptor))
        self.title = title
    }

    var body: some View {
        Section {
            ForEach(items) {
                ListItem()
                    .environment($0)
            }
            .onDelete {
                Haptic.warning.impact()
                willDeleteItems = $0.map {
                    items[$0]
                }
                isDialogPresented = true
            }
        } header: {
            if let title {
                Text(title)
            }
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: $isDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try willDeleteItems.forEach {
                        try DeleteItemIntent.perform((context: context, item: $0))
                    }
                    Haptic.success.impact()
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
        } message: {
            Text("Are you sure you want to delete this item?")
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
