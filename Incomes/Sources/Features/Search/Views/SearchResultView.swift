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

    @LedgerItemQuery private var items: [Item]

    @Environment(\.ledgerBalances)
    private var ledgerBalances
    private let predicate: ItemPredicate

    let refineSearch: (() -> Void)?

    private var matchingItems: [Item] {
        guard case let .balanceIsBetween(minimum, maximum) = predicate else {
            return items
        }
        return items.filter { item in
            guard let value = ledgerBalances[item.persistentModelID] else {
                return false
            }
            return minimum <= value && value <= maximum
        }
    }

    private var sections: [SearchResultOperations.Section] {
        SearchResultOperations.sections(for: matchingItems)
    }

    init(
        predicate: ItemPredicate,
        refineSearch: (() -> Void)? = nil,
        ledgerIdentifier: LedgerIdentifier = .default
    ) {
        self.predicate = predicate
        self.refineSearch = refineSearch
        _items = LedgerItemQuery(.items(
            predicate.requiresDerivedBalance ? .all : predicate,
            ledgerIdentifier: ledgerIdentifier
        ))
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
            ItemCountStatusToolbarItem(count: matchingItems.count)
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
