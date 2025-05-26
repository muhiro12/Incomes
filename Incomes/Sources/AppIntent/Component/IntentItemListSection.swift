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
            ForEach(items) {
                NarrowListItem()
                    .environment($0)
            }
        }
        .safeAreaPadding()
    }
}

#Preview {
    IncomesPreview { preview in
        IntentItemListSection(preview.items)
    }
}
