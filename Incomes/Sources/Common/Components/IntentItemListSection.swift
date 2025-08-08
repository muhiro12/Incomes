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
    @Environment(\.modelContext)
    private var context

    private var items: [ItemEntity]

    init(_ items: [ItemEntity]) {
        self.items = items
    }

    var body: some View {
        Section {
            ForEach(items) { item in
                if let model = try? item.model(in: context) {
                    NarrowListItem()
                        .environment(model)
                }
            }
        }
        .safeAreaPadding()
    }
}

#Preview {
    IncomesPreview { preview in
        IntentItemListSection(preview.items.compactMap(ItemEntity.init))
    }
}
