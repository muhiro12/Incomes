//
//  TitleListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/07/08.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct TitleListItem: View {
    @Environment(Item.self) private var item

    var body: some View {
        HStack {
            Text(item.content)
                .font(.headline)
                .singleLine()
            Spacer()
            Image(systemName: "chevron.up")
                .foregroundStyle(item.netIncome.isPlus ? .accent : .clear)
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        TitleListItem()
            .environment(items.first(where: \.isNetIncomePositive))
    }
}
