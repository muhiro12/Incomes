//
//  DebugSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/05.
//

import SwiftData
import SwiftUI

struct DebugSection {
    @Environment(Item.self)
    private var item
}

extension DebugSection: View {
    var body: some View {
        Section {
            DebugValueRow(title: "Date", value: item.date.description)
            DebugValueRow(title: "Content", value: item.content)
            DebugValueRow(title: "Income", value: item.income.groupedDecimalText())
            DebugValueRow(title: "Outgo", value: item.outgo.groupedDecimalText())
            DebugValueRow(title: "Priority", value: item.priority.description)
            DebugValueRow(title: "RepeatID", value: item.repeatID.description)
            DebugValueRow(title: "Balance", value: item.balance.groupedDecimalText())
            DebugTagsRow(tags: item.tags ?? [])
        } header: {
            Text("Debug")
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        DebugSection()
            .environment(items[0])
    }
}
