//
//  CategoryChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import MHDesign
import SwiftData
import SwiftUI

struct CategoryChartSection: View {
    @Query private var items: [Item]
    @Environment(\.mhDesignMetrics)
    private var designMetrics
    private let allowsExpansion: Bool

    var body: some View {
        Section {
            switch Result(catching: chartSummary) {
            case .success(let summary):
                ZoomableChartSection(
                    title: "Category",
                    transitionID: "category",
                    allowsExpansion: allowsExpansion
                ) {
                    chartContent(summary)
                } detail: {
                    ScrollView {
                        chartContent(summary)
                            .padding(.vertical, designMetrics.layout.surface.compactInsetVertical)
                    }
                    .scrollIndicators(.hidden)
                }
            case .failure(let error):
                Text(ErrorMessageOperations.message(from: error))
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Category")
        }
    }

    init(
        _ descriptor: FetchDescriptor<Item>,
        allowsExpansion: Bool = true
    ) {
        _items = .init(descriptor)
        self.allowsExpansion = allowsExpansion
    }

    init(
        yearScopedTo date: Date,
        allowsExpansion: Bool = true
    ) {
        // Fetch year scope; apply non-zero filters in-memory
        _items = .init(.items(.dateIsSameYearAs(date)))
        self.allowsExpansion = allowsExpansion
    }
}

private extension CategoryChartSection {
    struct ChartSummary {
        let incomeSegments: [ItemSummaryOperations.ChartSegment]
        let outgoSegments: [ItemSummaryOperations.ChartSegment]
        let incomeTotal: Decimal
        let outgoTotal: Decimal
    }

    func chartSummary() throws -> ChartSummary {
        .init(
            incomeSegments: try ItemSummaryOperations.incomeSegments(for: items),
            outgoSegments: try ItemSummaryOperations.outgoSegments(for: items),
            incomeTotal: try ItemSummaryOperations.totalIncome(for: items),
            outgoTotal: try ItemSummaryOperations.totalOutgo(for: items)
        )
    }

    func chartContent(_ summary: ChartSummary) -> some View {
        CategoryChartContent(
            incomeSegments: summary.incomeSegments,
            outgoSegments: summary.outgoSegments,
            incomeTotal: summary.incomeTotal,
            outgoTotal: summary.outgoTotal,
            incomeColorScale: colorScale(for: summary.incomeSegments, baseColor: .accent),
            outgoColorScale: colorScale(for: summary.outgoSegments, baseColor: .red)
        )
    }

    func colorScale(
        for segments: [ItemSummaryOperations.ChartSegment],
        baseColor: Color
    ) -> [String: Color] {
        .init(
            uniqueKeysWithValues: segments.enumerated().map { index, object in
                (
                    object.label,
                    adjustedChartColor(
                        forRank: index,
                        totalCount: segments.count,
                        baseColor: baseColor
                    )
                )
            }
        )
    }

    func adjustedChartColor(forRank index: Int, totalCount: Int, baseColor: Color) -> Color {
        guard totalCount >= CategoryChartMetrics.minimumColorVariantCount else {
            return baseColor
        }
        let lastColorRank = totalCount - 1
        let clampedIndex = min(max(index, CategoryChartMetrics.firstColorRank), lastColorRank)
        let progress = Double(clampedIndex) / Double(lastColorRank)
        let percentage = CategoryChartMetrics.maximumColorAdjustment * progress
        return ChartColorAdjustment.adjustedColor(baseColor, by: percentage)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    List {
        CategoryChartSection(yearScopedTo: .now)
    }
}

#Preview("Inexact totals", traits: .modifier(IncomesInexactTotalSampleData())) {
    List {
        CategoryChartSection(.items(.all))
    }
}
