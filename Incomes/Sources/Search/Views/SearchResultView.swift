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

    private var sections: [SearchResultSectionBuilder.Section] {
        SearchResultSectionBuilder.sections(for: items)
    }

    var body: some View {
        Group {
            if items.isNotEmpty {
                List {
                    ForEach(
                        Array(sections.enumerated()),
                        id: \.element.month
                    ) { sectionIndex, section in
                        Section(section.title) {
                            ForEach(
                                Array(section.items.enumerated()),
                                id: \.element.persistentModelID
                            ) { itemIndex, item in
                                ListItem(
                                    isItemDetailTipAnchor: sectionIndex == .zero &&
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
