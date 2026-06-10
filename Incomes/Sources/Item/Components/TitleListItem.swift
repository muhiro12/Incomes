//
//  TitleListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/07/08.
//

import SwiftData
import SwiftUI

struct TitleListItem: View {
    @Environment(Item.self)
    private var item

    var body: some View {
        HStack {
            Text(item.content)
                .font(.headline)
                .singleLine()
            Spacer()
            PositiveNetIncomeIndicator(isVisible: item.netIncome.isPlus)
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        TitleListItem()
            .environment(items.first(where: \.isNetIncomePositive))
    }
}
