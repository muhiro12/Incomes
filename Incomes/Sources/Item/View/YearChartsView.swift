//
//  YearChartsView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 8/30/24.
//

import SwiftUI

struct YearChartsView: View {
    @Environment(Tag.self)
    private var yearTag
    @Environment(ItemService.self)
    private var itemService

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
            ToolbarItem {
                CreateItemButton()
            }
            ToolbarItem(placement: .status) {
                if let count = try? itemService.itemsCount(.items(.dateIsSameYearAs(date))) {
                    Text("\(count) Items")
                        .font(.footnote)
                }
            }
        }
    }
}

#Preview {
    IncomesPreview { preview in
        NavigationStack {
            YearChartsView()
                .environment(preview.tags.first { $0.type == .year })
        }
    }
}
