import Charts
import SwiftData
import SwiftUI

struct BalanceChart: View {
    @Environment(\.ledgerBalances)
    private var ledgerBalances

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
                balanceMarks(for: item)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: TimelineChartMetrics.xAxisMonthStride)) { _ in
                AxisGridLine()
                    .foregroundStyle(.secondary.opacity(TimelineChartMetrics.axisGridOpacity))
                AxisTick()
                    .foregroundStyle(.secondary.opacity(TimelineChartMetrics.axisTickOpacity))
                AxisValueLabel(collisionResolution: .greedy)
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
        .accessibilityLabel(Text("Balance chart"))
        .accessibilityValue(accessibilityValue)
    }
}

private extension BalanceChart {
    var accessibilityValue: Text {
        guard let latestItem,
              let latestBalance = ledgerBalances[latestItem.persistentModelID],
              let highestBalance,
              let lowestBalance else {
            return Text("No items")
        }
        return Text(verbatim: accessibilityValueParts(
            latestBalance: latestBalance,
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
        items.compactMap { ledgerBalances[$0.persistentModelID] }.max()
    }

    var lowestBalance: Decimal? {
        items.compactMap { ledgerBalances[$0.persistentModelID] }.min()
    }

    @ChartContentBuilder
    func balanceMarks(for item: Item) -> some ChartContent {
        if let balance = ledgerBalances[item.persistentModelID] {
            if items.count == 1 {
                PointMark(
                    x: .value("Date", item.localDate),
                    y: .value("Amount", balance)
                )
                .foregroundStyle(.tint)
            }
            AreaMark(
                x: .value("Date", item.localDate),
                y: .value("Amount", balance),
                stacking: .unstacked
            )
            .foregroundStyle(.tint)
            .interpolationMethod(.linear)
            .opacity(TimelineChartMetrics.areaMarkOpacity)
            LineMark(
                x: .value("Date", item.localDate),
                y: .value("Amount", balance)
            )
            .foregroundStyle(.tint)
            .interpolationMethod(.linear)
            .lineStyle(.init(lineWidth: TimelineChartMetrics.lineMarkWidth))
        }
    }

    func accessibilityValueParts(
        latestBalance: Decimal,
        highestBalance: Decimal,
        lowestBalance: Decimal
    ) -> [String] {
        [
            String(
                localized: "Latest balance: \(latestBalance.currencyText(locale: locale))",
                locale: locale
            ),
            String(
                localized: "Highest balance: \(highestBalance.currencyText(locale: locale))",
                locale: locale
            ),
            String(
                localized: "Lowest balance: \(lowestBalance.currencyText(locale: locale))",
                locale: locale
            )
        ]
    }
}
