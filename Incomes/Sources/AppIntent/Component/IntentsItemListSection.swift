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
    @Query private var items: [Item]

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = Query(descriptor)
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
    IncomesPreview { _ in
        IntentsItemListSection(.items(.dateIsSameMonthAs(.now)))
    }
}
