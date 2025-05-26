//
//  IntentsItemListSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct IntentsItemListSection: View {
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
    }
}

#Preview {
    IncomesPreview { preview in
        IntentsItemListSection(preview.items)
    }
}
