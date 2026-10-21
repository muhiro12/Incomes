//
//  MonthlySummarySection.swift
//  Incomes
//
//  Created by Codex on 2026/03/04.
//

import MHPlatform
import SwiftData
import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummarySection: View {
    @Environment(\.locale)
    private var locale

    @LedgerItemQuery private var currentItems: [Item]

    @LedgerItemQuery private var previousItems: [Item]

    private let date: Date

    var body: some View {
        Color.clear
            .frame(width: .zero, height: .zero)
            .toolbar {
                MonthlySummaryToolbarContent(
                    isVisible: shouldDisplaySummaryControl,
                    date: date,
                    currentItems: currentItems,
                    previousItems: previousItems
                )
            }
    }

    init(
        date: Date,
        currentItemsDescriptor: ItemFetchDescriptor? = nil,
        ledgerIdentifier: LedgerIdentifier = .default
    ) {
        self.date = date
        _currentItems = .init(
            currentItemsDescriptor ?? .items(.dateIsSameMonthAs(date), ledgerIdentifier: ledgerIdentifier)
        )
        _previousItems = .init(
            .items(
                .dateIsSameMonthAs(
                    MonthlySummaryOperations.previousMonthDate(from: date)
                ),
                ledgerIdentifier: ledgerIdentifier
            )
        )
    }
}

@available(iOS 26.0, *)
private extension MonthlySummarySection {
    var shouldDisplaySummaryControl: Bool {
        guard !currentItems.isEmpty else {
            return false
        }
        return MonthlySummaryGenerator.canGenerate(locale: locale)
    }
}
