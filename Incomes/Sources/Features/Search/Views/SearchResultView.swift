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

    let refineSearch: (() -> Void)?

    private var sections: [SearchResultOperations.Section] {
        SearchResultOperations.sections(for: items)
    }

    init(
        predicate: ItemPredicate,
        refineSearch: (() -> Void)? = nil
    ) {
        self.refineSearch = refineSearch
        _items = Query(.items(predicate))
    }
}

extension SearchResultView {
    @ViewBuilder var body: some View {
        let resultSections = sections
        let firstItemID = resultSections.first?.items.first?.persistentModelID

        SearchResultContent(
            sections: resultSections,
            firstItemID: firstItemID,
            refineSearch: refineSearch
        )
        .navigationTitle("Results")
        .toolbar {
            ItemCountStatusToolbarItem(count: items.count)
        }
        .toolbar {
            CreateItemToolbarContent()
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
        SearchResultView(predicate: .matchingNone)
    }
}
