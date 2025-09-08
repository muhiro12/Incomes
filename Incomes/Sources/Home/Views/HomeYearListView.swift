//
//  HomeYearListView.swift
//  Incomes
//
//  Created by Codex on 2025/09/09.
//

import SwiftData
import SwiftUI

struct HomeYearListView: View {
    private let yearTag: Tag

    @Environment(\.modelContext)
    private var context

    @Query private var yearMonthTags: [Tag]

    @State private var isDialogPresented = false
    @State private var willDeleteItems: [Item] = []

    init(yearTag: Tag) {
        self.yearTag = yearTag
        _yearMonthTags = Query(
            .tags(
                .nameStartsWith(yearTag.name, type: .yearMonth),
                order: .reverse
            )
        )
    }

    var body: some View {
        List {
            Section("Year") {
                NavigationLink {
                    YearChartsView()
                        .environment(yearTag)
                } label: {
                    Label("Year Summary", systemImage: "chart.xyaxis.line")
                }
            }
            Section("Month") {
                ForEach(yearMonthTags) { tag in
                    let items = tag.items.orEmpty
                    NavigationLink {
                        ItemListGroup()
                            .environment(tag)
                    } label: {
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
        }
        .navigationTitle(Text(yearTag.displayName))
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

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            if let year = preview.tags.first(where: { $0.type == .year }) {
                HomeYearListView(yearTag: year)
            }
        }
    }
}
