import Charts
import SwiftUI

struct IncomeAndOutgoChart: View {
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
                AxisValueLabel()
            }
        }
    }
}
