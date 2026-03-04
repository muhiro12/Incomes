//
//  YearMonthItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/07/09.
//

import SwiftData
import SwiftUI
import TipKit

struct YearMonthItemListView {
    @Environment(Tag.self)
    private var tag

    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn

    private let itemDetailTip = ItemDetailTip()
}

extension YearMonthItemListView: View {
    var body: some View {
        ZStack {
            List {
                if items.isNotEmpty {
                    TipView(itemDetailTip)
                }
                ForEach(Array(yearStrings.enumerated()), id: \.element) { _, yearString in
                    ItemListSection(
                        .items(.tagAndYear(tag: tag, yearString: yearString))
                    )
                    if !isSubscribeOn {
                        AdvertisementSection(.medium)
                    }
                    ChartSectionGroup(
                        .items(.tagAndYear(tag: tag, yearString: yearString))
                    )
                }
            }
            if let monthDate {
                if #available(iOS 26.0, *) {
                    MonthlySummarySection(date: monthDate)
                }
            }
        }
        .listStyle(.grouped)
        .navigationTitle(tag.displayName)
        .toolbar {
            StatusToolbarItem("\(items.count) Items")
        }
        .toolbar {
            SpacerToolbarItem(placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                CreateItemButton()
            }
        }
    }
}

private extension YearMonthItemListView {
    var items: [Item] {
        tag.items.orEmpty
    }

    var monthDate: Date? {
        TagService.date(for: tag)
    }

    var yearStrings: [String] {
        TagService.yearStrings(for: tag)
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    NavigationStack {
        if let tag = tags.first(where: { previewTag in
            previewTag.type == .yearMonth
        }) {
            YearMonthItemListView()
                .environment(tag)
        }
    }
}
