//
//  IntentItemListSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct IntentItemListSection: View {
    private var items: [Item]

    init(_ items: [Item]) {
        self.items = items
    }

    var body: some View {
        Section {
            ForEach(items) { item in
                NarrowListItem()
                    .environment(item)
            }
        }
        .safeAreaPadding()
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    IntentItemListSection(items)
}
