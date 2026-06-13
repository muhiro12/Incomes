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

        SearchResultContent(
            sections: resultSections,
            firstItemID: firstItemID
        )
        .navigationTitle("Results")
        .toolbar {
            ItemCountStatusToolbarItem(count: items.count)
        }
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
