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
        tag.name.dateValueWithoutLocale(.yyyy) ?? .distantPast
    }

    var body: some View {
        List {
            ChartSectionGroup(.items(.dateIsSameYearAs(date)))
        }
        .navigationTitle(date.stringValue(.yyyy))
        .toolbar {
            if let count = try? ItemService.yearItemsCount(
                context: context,
                date: date
            ) {
                StatusToolbarItem("\(count) Items")
            }
        }
        .toolbar {
            SpacerToolbarItem(placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                CreateItemButton()
            }
        }
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            if let tag = preview.tags.first(where: { $0.type == .year }) {
                YearChartsView()
                    .environment(tag)
            }
        }
    }
}
