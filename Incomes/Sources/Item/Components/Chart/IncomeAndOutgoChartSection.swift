//
//  IncomeAndOutgoChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import SwiftData
import SwiftUI

struct IncomeAndOutgoChartSection: View {
    @Query private var items: [Item]

    private let allowsExpansion: Bool

    var body: some View {
        Section {
            ZoomableChartSection(
                title: "Income and Outgo",
                transitionID: "incomeAndOutgo",
                allowsExpansion: allowsExpansion
            ) {
                TimelineChartPreview {
                    IncomeAndOutgoChart(items: items)
                }
            } detail: {
                TimelineChartDetail {
                    IncomeAndOutgoChart(items: items)
                }
            }
        } header: {
            Text("Income and Outgo")
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
        IncomeAndOutgoChartSection(.items(.dateIsSameYearAs(.now)))
    }
}
