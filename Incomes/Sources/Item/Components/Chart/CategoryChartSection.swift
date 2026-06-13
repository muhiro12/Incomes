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
        let incomeSegments = ItemSummaryOperations.incomeSegments(for: items)
        let outgoSegments = ItemSummaryOperations.outgoSegments(for: items)
        let incomeTotal = ItemSummaryOperations.totalIncome(for: items)
        let outgoTotal = ItemSummaryOperations.totalOutgo(for: items)
        let incomeColorScale = colorScale(for: incomeSegments, baseColor: .accent)
        let outgoColorScale = colorScale(for: outgoSegments, baseColor: .red)

        Section {
            ZoomableChartSection(
                title: "Category",
                transitionID: "category",
                allowsExpansion: allowsExpansion
            ) {
                CategoryChartContent(
                    incomeSegments: incomeSegments,
                    outgoSegments: outgoSegments,
                    incomeTotal: incomeTotal,
                    outgoTotal: outgoTotal,
                    incomeColorScale: incomeColorScale,
                    outgoColorScale: outgoColorScale
                )
            } detail: {
                ScrollView {
                    CategoryChartContent(
                        incomeSegments: incomeSegments,
                        outgoSegments: outgoSegments,
                        incomeTotal: incomeTotal,
                        outgoTotal: outgoTotal,
                        incomeColorScale: incomeColorScale,
                        outgoColorScale: outgoColorScale
                    )
                    .padding(.vertical, designMetrics.layout.surface.compactInsetVertical)
                }
                .scrollIndicators(.hidden)
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
