import Charts
import SwiftUI

struct BalanceChart: View {
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
    }
}
