//
//  IncomeAndOutgoChartSection.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Charts
import MHDesign
import SwiftData
import SwiftUI

struct IncomeAndOutgoChartSection: View {
    @Query private var items: [Item]
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    private let allowsExpansion: Bool

    var body: some View {
        Section {
            ZoomableChartSection(
                title: "Income and Outgo",
                transitionID: "incomeAndOutgo",
                allowsExpansion: allowsExpansion
            ) {
                chart()
                    .frame(height: Constants.sectionHeight)
                    .padding(designMetrics.spacing.control)
            } detail: {
                chart()
                    .chartScrollableAxes(.horizontal)
                    .chartScrollPosition(initialX: Date.now)
                    .padding(designMetrics.spacing.control)
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

private extension IncomeAndOutgoChartSection {
    private enum Constants {
        static let axisGridOpacity = 0.2
        static let axisTickOpacity = 0.4
        static let barOpacity = 0.6
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
                if income(of: item).isNotZero {
                    BarMark(
                        x: .value("Date", date(of: item)),
                        y: .value("Amount", income(of: item)),
                        stacking: .unstacked
                    )
                    .foregroundStyle(.green)
                    .opacity(Constants.barOpacity)
                }
                if outgo(of: item).isNotZero {
                    BarMark(
                        x: .value("Date", date(of: item)),
                        y: .value("Amount", outgo(of: item)),
                        stacking: .unstacked
                    )
                    .foregroundStyle(.red)
                    .opacity(Constants.barOpacity)
                }
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

    func income(of item: Item) -> Decimal {
        item.income
    }

    func outgo(of item: Item) -> Decimal {
        item.outgo * -1
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        IncomeAndOutgoChartSection(.items(.dateIsSameYearAs(.now)))
    }
}
