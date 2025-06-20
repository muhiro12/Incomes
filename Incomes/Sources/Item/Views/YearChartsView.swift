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
    private var yearTag
    @Environment(\.modelContext)
    private var context

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    var date: Date {
        yearTag.name.dateValueWithoutLocale(.yyyy) ?? .distantPast
    }

    var body: some View {
        List {
            ChartSectionGroup(.items(.dateIsSameYearAs(date)))
        }
        .navigationTitle(date.stringValue(.yyyy))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                ToolbarAlignmentSpacer()
            }
            ToolbarItem(placement: .status) {
                if let count = try? GetYearItemsCountIntent.perform(
                    (context: context, date: date)
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
            YearChartsView()
                .environment(
                    preview.tags.first {
                        $0.type == .year
                    }
                )
        }
    }
}
