import MHDesign
import SwiftUI

struct CategoryChartContent: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let incomeSegments: [ItemSummaryOperations.ChartSegment]
    let outgoSegments: [ItemSummaryOperations.ChartSegment]
    let incomeTotal: Decimal
    let outgoTotal: Decimal
    let incomeColorScale: [String: Color]
    let outgoColorScale: [String: Color]

    var body: some View {
        VStack(spacing: designMetrics.spacing.section) {
            CategoryChartPanel(
                title: "Income",
                segments: incomeSegments,
                total: incomeTotal,
                colorScale: incomeColorScale,
                fallbackColor: .accent
            )
            CategoryChartPanel(
                title: "Outgo",
                segments: outgoSegments,
                total: outgoTotal,
                colorScale: outgoColorScale,
                fallbackColor: .red
            )
            .padding(.top, designMetrics.spacing.inline)
        }
        .padding(.horizontal, designMetrics.layout.surface.insetHorizontal)
    }
}
