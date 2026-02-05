//
//  ItemListGroup.swift
//  Incomes
//
//  Created by Codex on 2025/07/09.
//

import SwiftData
import SwiftUI

struct ItemListGroup {
    @Environment(Tag.self)
    private var tag
}

extension ItemListGroup: View {
    var body: some View {
        switch tag.type {
        case .year:
            YearChartsView()
        case .yearMonth:
            YearMonthItemListView()
        case .content:
            ContentItemListView()
        case .category:
            CategoryItemListView()
        case .debug:
            EmptyView()
        case .none:
            EmptyView()
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    ItemListGroup()
        .environment(tags[0])
}
