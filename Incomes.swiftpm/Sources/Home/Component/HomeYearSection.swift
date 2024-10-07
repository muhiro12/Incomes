//
//  HomeYearSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/7/24.
//

import SwiftData
import SwiftUI

struct HomeYearSection {
    @Environment(ItemService.self)
    private var itemService

    @Query private var tags: [Tag]

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    private let yearTag: Tag

    init(yearTag: Tag) {
        self.yearTag = yearTag
        self._tags = Query(.tags(.yearIs(yearTag.name), order: .reverse))
    }
}

extension HomeYearSection: View {
    var body: some View {
        Section {
            ForEach(tags) { tag in
                if let items = tag.items,
                   let first = items.first {
                    NavigationLink(value: IncomesPath.itemList(tag)) {
                        Text(first.date.stringValue(.yyyyMMM))
                            .foregroundStyle(
                                items.contains {
                                    $0.balance.isMinus
                                } ? .red : .primary
                            )
                    }
                }
            }.onDelete {
                isPresentedToAlert = true
                willDeleteItems = $0.flatMap { tags[$0].items ?? [] }
            }
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
    IncomesPreview { preview in
        List {
            HomeYearSection(yearTag: preview.tags.first { $0.type == .year }!)
        }
    }
}
