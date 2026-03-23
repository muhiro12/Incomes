//
//  SearchResultView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//

import SwiftData
import SwiftUI

struct SearchResultView: View {
    @Environment(IncomesTipController.self)
    private var tipController

    @Query private var items: [Item]

    init(predicate: ItemPredicate) { // swiftlint:disable:this type_contents_order
        _items = Query(.items(predicate))
    }

    private var groupedItems: [Date: [Item]] {
        Dictionary(grouping: items) { item in
            Calendar.current.startOfMonth(for: item.localDate)
        }
    }

    private var sortedMonths: [Date] {
        groupedItems.keys.sorted(by: >)
    }

    var body: some View {
        Group {
            if items.isNotEmpty {
                List {
                    ForEach(Array(sortedMonths.enumerated()), id: \.element) { monthIndex, month in
                        Section(month.formatted(.dateTime.year().month())) {
                            ForEach(
                                Array((groupedItems[month] ?? []).enumerated()),
                                id: \.element.persistentModelID
                            ) { itemIndex, item in
                                ListItem(
                                    isItemDetailTipAnchor: monthIndex == .zero &&
                                        itemIndex == .zero
                                )
                                .environment(item)
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Adjust your filters to find matching income items.")
                )
            }
        }
        .navigationTitle("Results")
        .task(id: items.count) {
            guard items.isNotEmpty else {
                return
            }
            tipController.donateDidViewItemList()
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        SearchResultView(predicate: .all)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        SearchResultView(predicate: .none)
    }
}
