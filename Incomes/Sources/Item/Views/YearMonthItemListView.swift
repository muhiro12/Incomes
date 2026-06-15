//
//  YearMonthItemListView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/07/09.
//

import MHPlatform
import SwiftData
import SwiftUI

struct YearMonthItemListView {
    @Environment(Tag.self)
    private var tag
    @Environment(IncomesTipController.self)
    private var tipController

    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(\.isDebugOn)
    private var isDebugOn
}

extension YearMonthItemListView: View {
    var body: some View {
        let currentYearStrings = yearStrings
        let firstYearString = currentYearStrings.first

        ZStack {
            List {
                ForEach(currentYearStrings, id: \.self) { yearString in
                    ItemListSection(
                        .items(.tagAndYear(tag: tag, yearString: yearString)),
                        showsItemDetailTip: yearString == firstYearString
                    )
                    if !isSubscribeOn {
                        AdvertisementSection(.medium)
                    }
                    ChartSectionGroup(
                        .items(.tagAndYear(tag: tag, yearString: yearString))
                    )
                }
            }
            if isDebugOn,
               let monthDate {
                if #available(iOS 26.0, *) {
                    MonthlySummarySection(date: monthDate)
                }
            }
        }
        .listStyle(.grouped)
        .navigationTitle(tag.displayName)
        .task(id: items.count) {
            guard !items.isEmpty else {
                return
            }
            tipController.donateDidViewItemList()
        }
        .toolbar {
            ItemCountStatusToolbarItem(count: items.count)
        }
        .toolbar {
            CreateItemToolbarContent()
        }
    }
}

private extension YearMonthItemListView {
    var items: [Item] {
        tag.items ?? []
    }

    var monthDate: Date? {
        TagQueryOperations.date(for: tag)
    }

    var yearStrings: [String] {
        TagQueryOperations.yearStrings(for: tag)
    }
}

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
