//
//  CategoryChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
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
            ZoomableChartSection(
                title: "Category",
                transitionID: "category",
                allowsExpansion: allowsExpansion
            ) {
                chartContent
            } detail: {
                ScrollView {
                    chartContent
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
    private enum Constants {
        static let innerRadiusRatio = 0.618
        static let legendMarkerSize: CGFloat = 6
        static let outerRadiusInset: CGFloat = 10
        static let sectionHeight: CGFloat = 240
        static let sectorCornerRadius: CGFloat = 4
    }

    var chartContent: some View {
        VStack(spacing: designMetrics.spacing.section) {
            incomeContent
            outgoContent
        }
        .padding(.horizontal, designMetrics.layout.surface.insetHorizontal)
    }

    @ViewBuilder var incomeContent: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text("Income")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                Chart(incomeObjects, id: \.title) { object in
                    SectorMark(
                        angle: .value(
                            object.title,
                            object.plotValue
                        ),
                        innerRadius: .ratio(Constants.innerRadiusRatio),
                        outerRadius: .inset(Constants.outerRadiusInset),
                        angularInset: 1
                    )
                    .cornerRadius(Constants.sectorCornerRadius)
                    .foregroundStyle(by: .value("Category", object.label))
                }
                .chartForegroundStyleScale { (label: String) in
                    incomeColorScale[label] ?? .accent
                }
                .chartLegend(.hidden)
                totalLabel(amount: incomeTotal)
            }
            .frame(height: Constants.sectionHeight)
            incomeLegend
        }
    }

    @ViewBuilder var outgoContent: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text("Outgo")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                Chart(outgoObjects, id: \.title) { object in
                    SectorMark(
                        angle: .value(
                            object.title,
                            object.plotValue
                        ),
                        innerRadius: .ratio(Constants.innerRadiusRatio),
                        outerRadius: .inset(Constants.outerRadiusInset),
                        angularInset: 1
                    )
                    .cornerRadius(Constants.sectorCornerRadius)
                    .foregroundStyle(by: .value("Category", object.label))
                }
                .chartForegroundStyleScale { (label: String) in
                    outgoColorScale[label] ?? .red
                }
                .chartLegend(.hidden)
                totalLabel(amount: outgoTotal)
            }
            .frame(height: Constants.sectionHeight)
            outgoLegend
        }
        .padding(.top, designMetrics.spacing.inline)
    }

    @ViewBuilder
    func totalLabel(amount: Decimal) -> some View { // swiftlint:disable:this type_contents_order
        VStack(spacing: designMetrics.spacing.inline) {
            Text("Total")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(amount.asCurrency)
                .font(.headline)
        }
    }

    @ViewBuilder var incomeLegend: some View {
        legendList(objects: incomeObjects, colorScale: incomeColorScale)
    }

    @ViewBuilder var outgoLegend: some View {
        legendList(objects: outgoObjects, colorScale: outgoColorScale)
    }
}

private extension CategoryChartSection {
    var incomeTotal: Decimal {
        ItemSummaryOperations.totalIncome(for: items)
    }

    var outgoTotal: Decimal {
        ItemSummaryOperations.totalOutgo(for: items)
    }

    var incomeObjects: [ItemSummaryOperations.ChartSegment] {
        ItemSummaryOperations.incomeSegments(for: items)
    }

    var outgoObjects: [ItemSummaryOperations.ChartSegment] {
        ItemSummaryOperations.outgoSegments(for: items)
    }

    var incomeColorScale: [String: Color] {
        .init(
            uniqueKeysWithValues: incomeObjects.enumerated().map { index, object in
                (
                    object.label,
                    adjustedChartColor(
                        forRank: index,
                        totalCount: incomeObjects.count,
                        baseColor: .accent
                    )
                )
            }
        )
    }

    var outgoColorScale: [String: Color] {
        .init(
            uniqueKeysWithValues: outgoObjects.enumerated().map { index, object in
                (
                    object.label,
                    adjustedChartColor(
                        forRank: index,
                        totalCount: outgoObjects.count,
                        baseColor: .red
                    )
                )
            }
        )
    }

    func adjustedChartColor(forRank index: Int, totalCount: Int, baseColor: Color) -> Color {
        guard totalCount > 1 else {
            return baseColor
        }
        let clampedIndex = min(max(index, 0), totalCount - 1)
        let progress = Double(clampedIndex) / Double(totalCount - 1)
        let maxAdjustment = 80.0
        let percentage = maxAdjustment * progress
        return baseColor.adjusted(by: percentage)
    }

    @ViewBuilder
    func legendList(
        objects: [ItemSummaryOperations.ChartSegment],
        colorScale: [String: Color]
    ) -> some View {
        let columns: [GridItem] = [
            .init(.flexible(), spacing: designMetrics.spacing.inline, alignment: .leading),
            .init(.flexible(), spacing: designMetrics.spacing.inline, alignment: .leading)
        ]
        LazyVGrid(columns: columns, alignment: .leading) {
            ForEach(objects, id: \.label) { object in
                VStack {
                    HStack {
                        Circle()
                            .fill(colorScale[object.label] ?? .secondary)
                            .frame(
                                width: Constants.legendMarkerSize,
                                height: Constants.legendMarkerSize
                            )
                        Text(object.title)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack {
                        Circle()
                            .fill(.clear)
                            .frame(
                                width: Constants.legendMarkerSize,
                                height: Constants.legendMarkerSize
                            )
                        Text("\(object.percentText), \(object.value.asCurrency)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(.top, designMetrics.spacing.inline)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    List {
        CategoryChartSection(yearScopedTo: .now)
    }
}
