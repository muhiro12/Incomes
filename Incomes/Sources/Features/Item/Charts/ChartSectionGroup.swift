//
//  ChartSectionGroup.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/06/03.
//

import MHPlatform
import SwiftData
import SwiftUI

struct ChartSectionGroup {
    @AppStorage(\.isSubscribeOn)
    private var isSubscribeOn

    private let descriptor: ItemFetchDescriptor
    private let yearScopedDate: Date?
    private let ledgerIdentifier: LedgerIdentifier

    init(_ descriptor: ItemFetchDescriptor) {
        self.descriptor = descriptor
        self.yearScopedDate = nil
        self.ledgerIdentifier = .default
    }

    init(yearScopedTo date: Date, ledgerIdentifier: LedgerIdentifier = .default) {
        self.descriptor = .items(.dateIsSameYearAs(date), ledgerIdentifier: ledgerIdentifier)
        self.ledgerIdentifier = ledgerIdentifier
        self.yearScopedDate = date
    }
}

extension ChartSectionGroup: View {
    var body: some View {
        BalanceChartSection(descriptor)
        IncomeAndOutgoChartSection(descriptor)
        if !isSubscribeOn {
            AdvertisementSection(.media)
        }
        if let date = yearScopedDate {
            CategoryChartSection(yearScopedTo: date, ledgerIdentifier: ledgerIdentifier)
        } else {
            CategoryChartSection(descriptor)
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        ChartSectionGroup(.items(.dateIsSameYearAs(.now)))
    }
}
