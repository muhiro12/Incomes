//
//  YearChartsView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 8/30/24.
//

import SwiftData
import SwiftUI

struct YearChartsView: View {
    @Environment(Tag.self)
    private var tag
    @Environment(\.modelContext)
    private var context

    var date: Date {
        TagQueryOperations.date(for: tag) ?? .distantPast
    }

    var body: some View {
        List {
            ChartSectionGroup(yearScopedTo: date)
        }
        .listStyle(.grouped)
        .navigationTitle(Text(date, format: .dateTime.year()))
        .toolbar {
            if let count = try? ItemQueryOperations.yearItemsCount(
                context: context,
                date: date
            ) {
                ItemCountStatusToolbarItem(count: count)
            }
        }
        .toolbar {
            CreateItemToolbarContent()
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    NavigationStack {
        if let tag = tags.first(where: { previewTag in
            previewTag.type == .year
        }) {
            YearChartsView()
                .environment(tag)
        }
    }
}
