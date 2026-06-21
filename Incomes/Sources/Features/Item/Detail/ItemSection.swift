//
//  ItemSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//

import SwiftData
import SwiftUI

struct ItemSection: View {
    @Environment(Item.self)
    private var item

    var body: some View {
        Section {
            ItemInformationRow(
                title: "Date"
            ) {
                Text(item.localDate, format: .dateTime.year().month().day())
            }
            ItemInformationRow(title: "Income") {
                Text(item.income.asCurrency)
            }
            ItemInformationRow(title: "Outgo") {
                Text(item.outgo.asMinusCurrency)
            }
            ItemCategoryInformationRow()
        } header: {
            Text("Information")
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    NavigationStack {
        List {
            ItemSection()
                .environment(items[0])
        }
    }
}
