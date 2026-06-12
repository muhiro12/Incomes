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

    private var sections: [SearchResultOperations.Section] {
        SearchResultOperations.sections(for: items)
    }

    var body: some View {
        let resultSections = sections
        let firstItemID = resultSections.first?.items.first?.persistentModelID

        Group {
            if !items.isEmpty {
                List {
                    ForEach(resultSections, id: \.month) { section in
                        Section(section.title) {
                            ForEach(section.items, id: \.persistentModelID) { item in
                                ListItem(
                                    isItemDetailTipAnchor:
                                        item.persistentModelID == firstItemID
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
            guard !items.isEmpty else {
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
