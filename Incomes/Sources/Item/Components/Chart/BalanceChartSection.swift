//
//  BalanceChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import SwiftData
import SwiftUI

struct BalanceChartSection: View {
    @Query private var items: [Item]

    private let allowsExpansion: Bool

    var body: some View {
        Section {
            ZoomableChartSection(
                title: "Balance",
                transitionID: "balance",
                allowsExpansion: allowsExpansion
            ) {
                TimelineChartPreview {
                    BalanceChart(items: items)
                }
            } detail: {
                TimelineChartDetail {
                    BalanceChart(items: items)
                }
            }
        } header: {
            Text("Balance")
        }
    }

    init(
        _ descriptor: FetchDescriptor<Item>,
        allowsExpansion: Bool = true
    ) {
        _items = Query(descriptor)
        self.allowsExpansion = allowsExpansion
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        BalanceChartSection(.items(.dateIsSameYearAs(.now)))
    }
}
