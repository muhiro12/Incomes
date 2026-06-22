//
//  NarrowListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//

import SwiftData
import SwiftUI

struct NarrowListItem: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            NarrowListItemAccessibilityLayout()
        } else {
            NarrowListItemStandardLayout()
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        NarrowListItem()
            .environment(items[0])
        NarrowListItem()
            .environment(items[1])
    }
}
