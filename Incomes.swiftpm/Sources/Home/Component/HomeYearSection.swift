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

    @Query private var yearMonthTags: [Tag]

    @State private var isPresentedToAlert = false
    @State private var willDeleteItems: [Item] = []

    init(yearTag: Tag) {
        _yearMonthTags = Query(.tags(.nameAndType(name: yearTag.name, type: .yearMonth), order: .reverse))
    }
}

extension HomeYearSection: View {
    var body: some View {
        Section {
            ForEach(yearMonthTags) { yearMonthTag in
                if let items = yearMonthTag.items,
                   let first = items.first {
                    NavigationLink(value: IncomesPath.itemList(yearMonthTag)) {
                        Text(first.date.stringValue(.yyyyMMM))
                            .foregroundStyle(
                                items.contains {
                                    $0.balance.isMinus
                                } ? .red : .primary
                            )
                            .bold(Calendar.utc.startOfMonth(for: first.date) == Calendar.utc.startOfMonth(for: .now))
                    }
                }
            }.onDelete {
                isPresentedToAlert = true
                willDeleteItems = $0.flatMap { yearMonthTags[$0].items ?? [] }
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
