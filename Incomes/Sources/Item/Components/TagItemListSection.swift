//
//  TagItemListSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/7/24.
//

import SwiftData
import SwiftUI

struct TagItemListSection {
    @Environment(Tag.self)
    private var tag
    @Environment(\.modelContext)
    private var context

    @State private var isDialogPresented = false
    @State private var willDeleteItems: [ItemEntity] = []

    private let yearString: String

    init(yearString: String) {
        self.yearString = yearString
    }
}

extension TagItemListSection: View {
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
            Text(yearString.dateValueWithoutLocale(.yyyy)?.stringValue(.yyyy) ?? .empty)
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: $isDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try willDeleteItems.forEach {
                        try DeleteItemIntent.perform(
                            (
                                container: context.container,
                                item: $0
                            )
                        )
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

private extension TagItemListSection {
    var items: [ItemEntity] {
        tag.items.orEmpty.filter {
            $0.year?.name == yearString
        }.sorted().compactMap(ItemEntity.init)
    }
}

#Preview {
    IncomesPreview { preview in
        List {
            TagItemListSection(yearString: Date.now.stringValueWithoutLocale(.yyyy))
                .environment(
                    preview.tags.first {
                        $0.type == .category
                    }
                )
        }
    }
}
