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
                        .padding(.vertical)
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
        static let contentSpacing: CGFloat = 4
        static let innerRadiusRatio = 0.618
        static let legendMarkerSize: CGFloat = 6
        static let legendTopPadding: CGFloat = 4
        static let outerRadiusInset: CGFloat = 10
        static let sectionHeight: CGFloat = 240
        static let sectorCornerRadius: CGFloat = 4
    }

    var chartContent: some View {
        VStack(spacing: designMetrics.spacing.section) {
            incomeContent
            outgoContent
        }
        .padding(.horizontal, designMetrics.spacing.control)
    }

    @ViewBuilder var incomeContent: some View {
        VStack(alignment: .leading, spacing: Constants.contentSpacing) {
            Text("Income")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                Chart(incomeObjects, id: \.title) { object in
                    SectorMark(
                        angle: .value(
                            object.title,
                            decimalToDouble(object.value)
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
        VStack(alignment: .leading, spacing: Constants.contentSpacing) {
            Text("Outgo")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                Chart(outgoObjects, id: \.title) { object in
                    SectorMark(
                        angle: .value(
                            object.title,
                            decimalToDouble(object.value)
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
        VStack(spacing: Constants.contentSpacing) {
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
        items.reduce(.zero) { result, item in
            result + item.income
        }
    }

    var outgoTotal: Decimal {
        items.reduce(.zero) { result, item in
            result + item.outgo
        }
    }

    var incomeObjects: [(title: String, value: Decimal, ratio: Double, label: String)] { // swiftlint:disable:this large_tuple line_length
        let source: [Item] = items.filter(\.income.isNotZero)
        let grouped: [String: [Item]] = .init(grouping: source) { item in
            CategoryNameSupport.displayName(
                forStoredName: item.category?.name
            )
        }
        let total = grouped.values
            .flatMap(\.self)
            .reduce(.zero) { result, item in
                result + item.income
            }
        return grouped.map { displayName, items in
            let value = items.reduce(.zero) { result, item in
                result + item.income
            }
            let ratio = ratioFor(value: value, total: total)
            let percent = percentString(for: ratio)
            let label = "\(displayName) \(percent) • \(value.asCurrency)"
            return (title: displayName, value: value, ratio: ratio, label: label)
        }
        .sorted { left, right in
            left.value > right.value
        }
    }

    var outgoObjects: [(title: String, value: Decimal, ratio: Double, label: String)] { // swiftlint:disable:this large_tuple line_length
        let source: [Item] = items.filter(\.outgo.isNotZero)
        let grouped: [String: [Item]] = .init(grouping: source) { item in
            CategoryNameSupport.displayName(
                forStoredName: item.category?.name
            )
        }
        let total = grouped.values
            .flatMap(\.self)
            .reduce(.zero) { result, item in
                result + item.outgo
            }
        return grouped.map { displayName, items in
            let value = items.reduce(.zero) { result, item in
                result + item.outgo
            }
            let ratio = ratioFor(value: value, total: total)
            let percent = percentString(for: ratio)
            let label = "\(displayName) \(percent) • \(value.asCurrency)"
            return (title: displayName, value: value, ratio: ratio, label: label)
        }
        .sorted { left, right in
            left.value > right.value
        }
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
        objects: [(title: String, value: Decimal, ratio: Double, label: String)], // swiftlint:disable:this large_tuple
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
                        Text("\(percentString(for: object.ratio)), \(object.value.asCurrency)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(.top, Constants.legendTopPadding)
    }

    func ratioFor(value: Decimal, total: Decimal) -> Double {
        guard total.isNotZero else {
            return .zero
        }
        let totalValue = decimalToDouble(total)
        let currentValue = decimalToDouble(value)
        return currentValue / totalValue
    }

    func percentString(for ratio: Double) -> String {
        ratio.formatted(.percent.precision(.fractionLength(0)))
    }

    private func decimalToDouble(_ value: Decimal) -> Double {
        Double(value.description) ?? .zero
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    List {
        CategoryChartSection(yearScopedTo: .now)
    }
}
