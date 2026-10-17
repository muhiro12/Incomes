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
    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

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
                        .items(.tagAndYear(tag: tag, yearString: yearString), ledgerIdentifier: ledgerIdentifier),
                        showsItemDetailTip: yearString == firstYearString
                    )
                    if !isSubscribeOn {
                        AdvertisementSection(.media)
                    }
                    ChartSectionGroup(
                        .items(.tagAndYear(tag: tag, yearString: yearString), ledgerIdentifier: ledgerIdentifier)
                    )
                }
            }
            if isDebugOn,
               let monthDate,
               let summaryItemsDescriptor {
                if #available(iOS 26.0, *) {
                    MonthlySummarySection(
                        date: monthDate,
                        currentItemsDescriptor: summaryItemsDescriptor,
                        ledgerIdentifier: ledgerIdentifier
                    )
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
        TagQueryOperations.items(for: tag, ledgerIdentifier: ledgerIdentifier)
    }

    var monthDate: Date? {
        TagQueryOperations.date(for: tag)
    }

    var yearStrings: [String] {
        TagQueryOperations.yearStrings(for: tag, ledgerIdentifier: ledgerIdentifier)
    }

    var summaryItemsDescriptor: ItemFetchDescriptor? {
        guard let yearString = yearStrings.first else {
            return nil
        }
        return .items(.tagAndYear(tag: tag, yearString: yearString), ledgerIdentifier: ledgerIdentifier)
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
