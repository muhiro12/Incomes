import Charts
import SwiftUI

struct IncomeAndOutgoChart: View {
    @Environment(\.locale)
    private var locale

    let items: [Item]

    var body: some View {
        let totalIncome = ItemSummaryOperations.totalIncome(for: items)
        let totalOutgo = ItemSummaryOperations.totalOutgo(for: items)
        let netIncome = totalIncome - totalOutgo

        Chart {
            RuleMark(y: .value("Zero", TimelineChartMetrics.zeroRuleYValue))
                .foregroundStyle(.secondary.opacity(TimelineChartMetrics.zeroRuleOpacity))
                .lineStyle(
                    .init(
                        lineWidth: TimelineChartMetrics.zeroRuleLineWidth,
                        dash: [TimelineChartMetrics.zeroRuleDashLength]
                    )
                )

            ForEach(items) { item in
                if item.income != .zero {
                    BarMark(
                        x: .value("Date", item.localDate),
                        y: .value("Amount", item.income),
                        stacking: .unstacked
                    )
                    .foregroundStyle(.green)
                    .opacity(TimelineChartMetrics.barOpacity)
                }
                if item.outgo != .zero {
                    BarMark(
                        x: .value("Date", item.localDate),
                        y: .value("Amount", item.outgo * -1),
                        stacking: .unstacked
                    )
                    .foregroundStyle(.red)
                    .opacity(TimelineChartMetrics.barOpacity)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: TimelineChartMetrics.xAxisMonthStride)) { _ in
                AxisGridLine()
                    .foregroundStyle(.secondary.opacity(TimelineChartMetrics.axisGridOpacity))
                AxisTick()
                    .foregroundStyle(.secondary.opacity(TimelineChartMetrics.axisTickOpacity))
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { _ in
                AxisGridLine()
                    .foregroundStyle(.secondary.opacity(TimelineChartMetrics.axisGridOpacity))
                AxisTick()
                    .foregroundStyle(.secondary.opacity(TimelineChartMetrics.axisTickOpacity))
                AxisValueLabel()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Income and Outgo chart"))
        .accessibilityValue(
            accessibilityValue(
                totalIncome: totalIncome,
                totalOutgo: totalOutgo,
                netIncome: netIncome
            )
        )
    }
}

private extension IncomeAndOutgoChart {
    func accessibilityValue(
        totalIncome: Decimal,
        totalOutgo: Decimal,
        netIncome: Decimal
    ) -> Text {
        guard !items.isEmpty else {
            return Text("No items")
        }
        return Text(verbatim: accessibilityValueParts(
            totalIncome: totalIncome,
            totalOutgo: totalOutgo,
            netIncome: netIncome
        )
        .formatted(.list(type: .and).locale(locale)))
    }

    func accessibilityValueParts(
        totalIncome: Decimal,
        totalOutgo: Decimal,
        netIncome: Decimal
    ) -> [String] {
        [
            String(localized: "Total income: \(totalIncome.asCurrency)"),
            String(localized: "Total outgo: \(totalOutgo.asMinusCurrency)"),
            String(localized: "Net income: \(netIncome.asCurrency)")
        ]
    }
}
