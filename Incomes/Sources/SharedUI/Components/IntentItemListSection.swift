//
//  IntentItemListSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//

import SwiftData
import SwiftUI

struct IntentItemListSection: View {
    private var items: [Item]

    init(_ items: [Item]) {
        self.items = items
    }
}

extension IntentItemListSection {
    @ViewBuilder var body: some View {
        Section {
            ForEach(items) { item in
                NarrowListItem()
                    .environment(item)
            }
        }
        .safeAreaPadding()
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    IntentItemListSection(items)
}
