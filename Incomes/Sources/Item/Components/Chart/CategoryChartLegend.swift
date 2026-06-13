import MHDesign
import SwiftUI

struct CategoryChartLegend: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let segments: [ItemSummaryOperations.ChartSegment]
    let colorScale: [String: Color]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading) {
            ForEach(segments, id: \.label) { segment in
                CategoryChartLegendItem(
                    segment: segment,
                    markerColor: colorScale[segment.label] ?? .secondary
                )
            }
        }
        .padding(.top, designMetrics.spacing.inline)
    }
}

private extension CategoryChartLegend {
    var columns: [GridItem] {
        [
            .init(.flexible(), spacing: designMetrics.spacing.inline, alignment: .leading),
            .init(.flexible(), spacing: designMetrics.spacing.inline, alignment: .leading)
        ]
    }
}
