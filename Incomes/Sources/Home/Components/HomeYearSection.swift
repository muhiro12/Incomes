//
//  HomeYearSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/7/24.
//

import SwiftData
import SwiftUI

struct HomeYearSection: View {
    @Environment(\.modelContext)
    private var context

    @Query private var yearMonthTags: [Tag]

    @State private var isDialogPresented = false
    @State private var willDeleteItems: [Item] = []

    init(yearTag: Tag) {
        _yearMonthTags = Query(
            .tags(
                .nameStartsWith(yearTag.name, type: .yearMonth),
                order: .reverse
            )
        )
    }

    var body: some View {
        Section {
            ForEach(yearMonthTags) { tag in
                let items = tag.items.orEmpty
                NavigationLink(value: tag) {
                    Text(tag.displayName)
                        .foregroundStyle(
                            items.contains(where: \.balance.isMinus) ? .red : .primary
                        )
                        .bold(tag.name == Date.now.stringValueWithoutLocale(.yyyyMM))
                }
            }
            .onDelete { indices in
                Haptic.warning.impact()
                isDialogPresented = true
                willDeleteItems = indices.flatMap { yearMonthTags[$0].items.orEmpty }
            }
        }
        .confirmationDialog(
            Text("Delete"),
            isPresented: $isDialogPresented
        ) {
            Button(role: .destructive) {
                do {
                    try willDeleteItems.compactMap(ItemEntity.init).forEach {
                        try DeleteItemIntent.perform(
                            (
                                context: context,
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

#Preview {
    IncomesPreview { preview in
        List {
            HomeYearSection(
                yearTag: preview.tags
                    .first { $0.name == Date.now.stringValueWithoutLocale(.yyyy) }!
            )
        }
    }
}
