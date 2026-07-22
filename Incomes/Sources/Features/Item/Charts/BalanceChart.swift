import Charts
import SwiftUI

struct BalanceChart: View {
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
                AreaMark(
                    x: .value("Date", item.localDate),
                    y: .value("Amount", item.balance),
                    stacking: .unstacked
                )
                .foregroundStyle(.tint)
                .interpolationMethod(.linear)
                .opacity(TimelineChartMetrics.areaMarkOpacity)
                LineMark(
                    x: .value("Date", item.localDate),
                    y: .value("Amount", item.balance)
                )
                .foregroundStyle(.tint)
                .interpolationMethod(.linear)
                .lineStyle(.init(lineWidth: TimelineChartMetrics.lineMarkWidth))
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
        .accessibilityLabel(Text("Balance chart"))
        .accessibilityValue(accessibilityValue)
    }
}

private extension BalanceChart {
    var accessibilityValue: Text {
        guard let latestItem,
              let highestBalance,
              let lowestBalance else {
            return Text("No items")
        }
        return Text(verbatim: accessibilityValueParts(
            latestBalance: latestItem.balance,
            highestBalance: highestBalance,
            lowestBalance: lowestBalance
        )
        .formatted(.list(type: .and).locale(locale)))
    }

    var latestItem: Item? {
        items.max { lhs, rhs in
            lhs.localDate < rhs.localDate
        }
    }

    var highestBalance: Decimal? {
        items.map(\.balance).max()
    }

    var lowestBalance: Decimal? {
        items.map(\.balance).min()
    }

    func accessibilityValueParts(
        latestBalance: Decimal,
        highestBalance: Decimal,
        lowestBalance: Decimal
    ) -> [String] {
        [
            String(localized: "Latest balance: \(latestBalance.asCurrency)"),
            String(localized: "Highest balance: \(highestBalance.asCurrency)"),
            String(localized: "Lowest balance: \(lowestBalance.asCurrency)")
        ]
    }
}
