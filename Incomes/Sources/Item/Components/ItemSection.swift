//
//  ItemSection.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI

struct ItemSection: View {
    @Environment(Item.self)
    private var item

    var body: some View {
        Section {
            HStack {
                Text("Date")
                Spacer()
                Text(item.localDate.stableStringValue(.yyyyMMMd))
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Income")
                Spacer()
                Text(item.income.asCurrency)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Outgo")
                Spacer()
                Text(item.outgo.asMinusCurrency)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Category")
                Spacer()
                Text(item.category?.displayName ?? .empty)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Information")
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        ItemSection()
            .environment(items[0])
    }
}
