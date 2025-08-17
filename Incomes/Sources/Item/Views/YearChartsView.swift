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

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    var date: Date {
        tag.name.dateValueWithoutLocale(.yyyy) ?? .distantPast
    }

    var body: some View {
        List {
            ChartSectionGroup(.items(.dateIsSameYearAs(date)))
        }
        .navigationTitle(date.stringValue(.yyyy))
        .toolbar {
            ToolbarAlignmentSpacer()
            ToolbarItem(placement: .status) {
                if let count = try? ItemService.yearItemsCount(
                    context: context,
                    date: date
                ) {
                    Text("\(count) Items")
                        .font(.footnote)
                }
            }
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
