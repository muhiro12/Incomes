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
    @State private var willDeleteItems: [Item] = []

    private let yearString: String

    init(yearString: String) {
        self.yearString = yearString
    }
}

extension TagItemListSection: View {
    var body: some View {
        Section {
            ForEach(items) { item in
                ListItem()
                    .environment(item)
            }
            .onDelete {
                Haptic.warning.impact()
                willDeleteItems = $0.map { index in
                    items[index]
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
                        try ItemService.delete(
                            context: context,
                            item: $0
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
    var items: [Item] {
        TagService.items(
            for: tag,
            yearString: yearString
        )
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    List {
        if let tag = tags.first(where: { previewTag in
            previewTag.type == .category
        }) {
            TagItemListSection(yearString: Date.now.stringValueWithoutLocale(.yyyy))
                .environment(tag)
        }
    }
}
