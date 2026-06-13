//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//

import SwiftData
import SwiftUI

struct ListItem {
    private let isItemDetailTipAnchor: Bool

    init(isItemDetailTipAnchor: Bool = false) {
        self.isItemDetailTipAnchor = isItemDetailTipAnchor
    }
}

extension ListItem: View {
    var body: some View {
        ListItemButton(
            isItemDetailTipAnchor: isItemDetailTipAnchor
        )
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        ListItem()
            .environment(items[0])
    }
}
