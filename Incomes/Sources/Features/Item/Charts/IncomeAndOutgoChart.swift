import Charts
import SwiftUI

struct IncomeAndOutgoChart: View {
    @Environment(\.locale)
    private var locale

    let items: [Item]

    var body: some View {
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
                AxisValueLabel(format: .chartAxisAmount(locale: locale))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Income and Outgo chart"))
        .accessibilityValue(accessibilityValue)
    }
}

private extension IncomeAndOutgoChart {
    var accessibilityValue: Text {
        guard !items.isEmpty else {
            return Text("No items")
        }
        do {
            return Text(verbatim: accessibilityValueParts(
                totals: try ItemSummaryOperations.totals(for: items)
            )
            .formatted(.list(type: .and).locale(locale)))
        } catch {
            return Text(ErrorMessageOperations.message(from: error))
        }
    }

    func accessibilityValueParts(
        totals: ItemSummaryOperations.MonthlyTotals
    ) -> [String] {
        [
            String(
                localized: "Total income: \(totals.totalIncome.currencyText(locale: locale))",
                locale: locale
            ),
            String(
                localized: "Total outgo: \(totals.totalOutgo.minusCurrencyText(locale: locale))",
                locale: locale
            ),
            String(
                localized: "Net income: \(totals.netIncome.currencyText(locale: locale))",
                locale: locale
            )
        ]
    }
}
