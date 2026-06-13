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
                fallbackColor: .accent,
                emptyStateTitle: "No Income Categories",
                emptyStateMessage: "Add income items with categories to see this chart."
            )
            CategoryChartPanel(
                title: "Outgo",
                segments: outgoSegments,
                total: outgoTotal,
                colorScale: outgoColorScale,
                fallbackColor: .red,
                emptyStateTitle: "No Outgo Categories",
                emptyStateMessage: "Add outgo items with categories to see this chart."
            )
            .padding(.top, designMetrics.spacing.inline)
        }
        .padding(.horizontal, designMetrics.layout.surface.insetHorizontal)
    }
}
