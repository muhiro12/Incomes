//
//  SearchTarget.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//

import SwiftUI

enum SearchTarget: CaseIterable {
    case content
    case category
    case balance
    case income
    case outgo

    var value: LocalizedStringKey {
        switch self {
        case .content:
            "Content"
        case .category:
            "Category"
        case .balance:
            "Balance"
        case .income:
            "Income"
        case .outgo:
            "Outgo"
        }
    }

    var isForCurrency: Bool {
        switch self {
        case .content,
             .category:
            false
        case .balance,
             .income,
             .outgo:
            true
        }
    }

    func predicate(minimumText: String, maximumText: String) -> ItemPredicate? {
        guard let target = searchPredicateTarget else {
            return nil
        }
        return ItemSearchPredicateBuilder.build(
            target: target,
            minimumText: minimumText,
            maximumText: maximumText
        )
    }

    func filteredTags(_ tags: [Tag], searchText: String) -> [Tag] {
        guard isForCurrency == false else {
            return []
        }

        return tags.filter { tag in
            searchText.isEmpty || tag.displayName.normalizedContains(searchText)
        }
    }
}

private extension SearchTarget {
    var searchPredicateTarget: ItemSearchPredicateBuilder.Target? {
        switch self {
        case .content,
             .category:
            return nil
        case .balance:
            return .balance
        case .income:
            return .income
        case .outgo:
            return .outgo
        }
    }
}
