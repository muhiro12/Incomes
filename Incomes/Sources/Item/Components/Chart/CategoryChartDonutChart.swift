import Charts
import SwiftUI

struct CategoryChartDonutChart: View {
    let segments: [ItemSummaryOperations.ChartSegment]
    let colorScale: [String: Color]
    let fallbackColor: Color

    var body: some View {
        Chart(segments, id: \.title) { segment in
            SectorMark(
                angle: .value(
                    segment.title,
                    segment.plotValue
                ),
                innerRadius: .ratio(CategoryChartMetrics.innerRadiusRatio),
                outerRadius: .inset(CategoryChartMetrics.outerRadiusInset),
                angularInset: 1
            )
            .cornerRadius(CategoryChartMetrics.sectorCornerRadius)
            .foregroundStyle(by: .value("Category", segment.label))
        }
        .chartForegroundStyleScale { (label: String) in
            colorScale[label] ?? fallbackColor
        }
        .chartLegend(.hidden)
    }
}
