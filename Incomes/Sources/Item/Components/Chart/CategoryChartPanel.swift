import MHDesign
import SwiftUI

struct CategoryChartPanel: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let title: LocalizedStringKey
    let segments: [ItemSummaryOperations.ChartSegment]
    let total: Decimal
    let colorScale: [String: Color]
    let fallbackColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                CategoryChartDonutChart(
                    segments: segments,
                    colorScale: colorScale,
                    fallbackColor: fallbackColor
                )
                CategoryChartTotalLabel(amount: total)
            }
            .frame(height: CategoryChartMetrics.sectionHeight)
            CategoryChartLegend(
                segments: segments,
                colorScale: colorScale
            )
        }
    }
}
