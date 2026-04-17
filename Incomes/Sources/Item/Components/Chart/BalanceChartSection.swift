//
//  BalanceChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
import MHDesign
import SwiftData
import SwiftUI

struct BalanceChartSection: View {
    @Query private var items: [Item]
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let allowsExpansion: Bool

    var body: some View {
        Section {
            ZoomableChartSection(
                title: "Balance",
                transitionID: "balance",
                allowsExpansion: allowsExpansion
            ) {
                chart()
                    .frame(height: Constants.sectionHeight)
                    .padding(.horizontal, designMetrics.layout.surface.insetHorizontal)
                    .padding(.vertical, designMetrics.layout.surface.insetVertical)
            } detail: {
                chart()
                    .chartScrollableAxes(.horizontal)
                    .chartScrollPosition(initialX: Date.now)
                    .padding(.horizontal, designMetrics.layout.surface.insetHorizontal)
                    .padding(.vertical, designMetrics.layout.surface.insetVertical)
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

private extension BalanceChartSection {
    private enum Constants {
        static let axisGridOpacity = 0.2
        static let axisTickOpacity = 0.4
        static let areaMarkOpacity = 0.2
        static let lineMarkWidth: CGFloat = 2
        static let sectionHeight: CGFloat = 240
        static let zeroRuleDashLength: CGFloat = 4
        static let zeroRuleLineWidth: CGFloat = 1
        static let zeroRuleOpacity = 0.25
        static let zeroRuleYValue: Double = .zero
        static let xAxisMonthStride = 3
    }

    func chart() -> some View {
        Chart {
            RuleMark(y: .value("Zero", Constants.zeroRuleYValue))
                .foregroundStyle(.secondary.opacity(Constants.zeroRuleOpacity))
                .lineStyle(
                    .init(
                        lineWidth: Constants.zeroRuleLineWidth,
                        dash: [Constants.zeroRuleDashLength]
                    )
                )

            ForEach(items) { item in
                AreaMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", balance(of: item)),
                    stacking: .unstacked
                )
                .foregroundStyle(.tint)
                .interpolationMethod(.linear)
                .opacity(Constants.areaMarkOpacity)
                LineMark(
                    x: .value("Date", date(of: item)),
                    y: .value("Amount", balance(of: item))
                )
                .foregroundStyle(.tint)
                .interpolationMethod(.linear)
                .lineStyle(.init(lineWidth: Constants.lineMarkWidth))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: Constants.xAxisMonthStride)) { _ in
                AxisGridLine()
                    .foregroundStyle(.secondary.opacity(Constants.axisGridOpacity))
                AxisTick()
                    .foregroundStyle(.secondary.opacity(Constants.axisTickOpacity))
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { _ in
                AxisGridLine()
                    .foregroundStyle(.secondary.opacity(Constants.axisGridOpacity))
                AxisTick()
                    .foregroundStyle(.secondary.opacity(Constants.axisTickOpacity))
                AxisValueLabel()
            }
        }
    }

    func date(of item: Item) -> Date {
        item.localDate
    }

    func balance(of item: Item) -> Decimal {
        item.balance
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        BalanceChartSection(.items(.dateIsSameYearAs(.now)))
    }
}
