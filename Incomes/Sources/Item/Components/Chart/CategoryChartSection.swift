//
//  CategoryChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
import SwiftData
import SwiftUI

struct CategoryChartSection: View {
    @Query private var items: [Item]

    init(_ descriptor: FetchDescriptor<Item>) {
        _items = .init(descriptor)
    }

    init(yearScopedTo date: Date) {
        // Fetch year scope; apply non-zero filters in-memory
        _items = .init(.items(.dateIsSameYearAs(date)))
    }

    var body: some View {
        Section {
            VStack(spacing: .space(.l)) {
                incomeContent
                outgoContent
            }
            .padding(.horizontal)
        } header: {
            Text("Category")
        }
    }
}

private extension CategoryChartSection {
    @ViewBuilder
    var incomeContent: some View {
        VStack(alignment: .leading, spacing: .space(.xs)) {
            Text("Income")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                Chart(incomeObjects, id: \.title) { object in
                    SectorMark(
                        angle: .value(
                            object.title,
                            NSDecimalNumber(decimal: object.value).doubleValue
                        ),
                        innerRadius: .ratio(0.618),
                        outerRadius: .inset(10),
                        angularInset: 1
                    )
                    .cornerRadius(4)
                    .foregroundStyle(by: .value("Category", object.label))
                }
                .chartForegroundStyleScale { (label: String) in
                    incomeColorScale[label] ?? .accent
                }
                .chartLegend(.hidden)
                totalLabel(amount: incomeTotal)
            }
            .frame(height: .component(.xl))
            incomeLegend
        }
    }

    @ViewBuilder
    var outgoContent: some View {
        VStack(alignment: .leading, spacing: .space(.xs)) {
            Text("Outgo")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                Chart(outgoObjects, id: \.title) { object in
                    SectorMark(
                        angle: .value(
                            object.title,
                            NSDecimalNumber(decimal: object.value).doubleValue
                        ),
                        innerRadius: .ratio(0.618),
                        outerRadius: .inset(10),
                        angularInset: 1
                    )
                    .cornerRadius(4)
                    .foregroundStyle(by: .value("Category", object.label))
                }
                .chartForegroundStyleScale { (label: String) in
                    outgoColorScale[label] ?? .red
                }
                .chartLegend(.hidden)
                totalLabel(amount: outgoTotal)
            }
            .frame(height: .component(.xl))
            outgoLegend
        }
        .padding(.top, .space(.s))
    }

    @ViewBuilder
    func totalLabel(amount: Decimal) -> some View {
        VStack(spacing: 4) {
            Text("Total")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(amount.asCurrency)
                .font(.headline)
        }
    }

    @ViewBuilder
    var incomeLegend: some View {
        legendList(objects: incomeObjects, colorScale: incomeColorScale)
    }

    @ViewBuilder
    var outgoLegend: some View {
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

    var incomeObjects: [(title: String, value: Decimal, ratio: Double, label: String)] {
        let source: [Item] = items.filter(\.income.isNotZero)
        let grouped: [String: [Item]] = .init(grouping: source) { item in
            item.category?.displayName ?? "Others"
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

    var outgoObjects: [(title: String, value: Decimal, ratio: Double, label: String)] {
        let source: [Item] = items.filter(\.outgo.isNotZero)
        let grouped: [String: [Item]] = .init(grouping: source) { item in
            item.category?.displayName ?? "Others"
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
        objects: [(title: String, value: Decimal, ratio: Double, label: String)],
        colorScale: [String: Color]
    ) -> some View {
        let columns: [GridItem] = [
            .init(.flexible(), spacing: .space(.s), alignment: .leading),
            .init(.flexible(), spacing: .space(.s), alignment: .leading)
        ]
        LazyVGrid(columns: columns, alignment: .leading) {
            ForEach(objects, id: \.label) { object in
                VStack {
                    HStack {
                        Circle()
                            .fill(colorScale[object.label] ?? .secondary)
                            .frame(width: 6, height: 6)
                        Text(object.title)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack {
                        Circle()
                            .fill(.clear)
                            .frame(width: 6, height: 6)
                        Text("\(percentString(for: object.ratio)), \(object.value.asCurrency)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(.top, .space(.xs))
    }

    func ratioFor(value: Decimal, total: Decimal) -> Double {
        guard total.isNotZero else {
            return 0
        }
        let totalValue = NSDecimalNumber(decimal: total).doubleValue
        let currentValue = NSDecimalNumber(decimal: value).doubleValue
        return currentValue / totalValue
    }

    func percentString(for ratio: Double) -> String {
        ratio.formatted(.percent.precision(.fractionLength(0)))
    }
}

@available(iOS 18.0, *)
#Preview(traits: .modifier(IncomesSampleData())) {
    List {
        CategoryChartSection(yearScopedTo: .now)
    }
}
