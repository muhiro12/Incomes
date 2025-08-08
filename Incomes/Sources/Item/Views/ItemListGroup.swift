//
//  ItemListGroup.swift
//  Incomes
//
//  Created by Codex on 2025/07/09.
//

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
        case .none:
            EmptyView()
        }
    }
}

#Preview {
    IncomesPreview { preview in
        ItemListGroup()
            .environment(preview.tags[0])
    }
}
