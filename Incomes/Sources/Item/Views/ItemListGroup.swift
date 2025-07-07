//
//  ItemListGroup.swift
//  Incomes
//
//  Created by Codex on 2025/07/09.
//

import SwiftUI

/// A view that selects the item list view based on the tag type in the
/// environment.
struct ItemListGroup {
    @Environment(TagEntity.self)
    private var tag
}

extension ItemListGroup: View {
    var body: some View {
        switch tag.type {
        case .year:
            YearItemListView()
        case .yearMonth:
            YearMonthItemListView()
        case .content:
            ContentItemListView()
        case .category:
            CategoryItemListView()
        case .none:
            EmptyView()
        }
    }
}

