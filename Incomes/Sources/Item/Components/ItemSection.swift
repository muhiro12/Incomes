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
            row(
                title: "Date",
                value: item.localDate.stringValue(.yyyyMMMd)
            )
            row(
                title: "Income",
                value: item.income.asCurrency
            )
            row(
                title: "Outgo",
                value: item.outgo.asMinusCurrency
            )
            categoryRow
        } header: {
            Text("Information")
        }
    }
}

private extension ItemSection {
    @ViewBuilder var categoryRow: some View {
        if let categoryTag = item.category {
            NavigationLink {
                CategoryItemListView()
                    .environment(categoryTag)
            } label: {
                row(
                    title: "Category",
                    value: categoryTag.displayName
                )
            }
        } else {
            row(
                title: "Category",
                value: CategoryFacetOperations.displayName(
                    forStoredCategoryName: nil
                )
            )
        }
    }

    func row(
        title: LocalizedStringKey,
        value: String
    ) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
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
