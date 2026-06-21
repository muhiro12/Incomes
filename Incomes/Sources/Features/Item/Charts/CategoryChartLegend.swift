import MHDesign
import SwiftUI

struct CategoryChartLegend: View {
    private enum Constants {
        static let accessibilityColumnCount = 1
        static let defaultColumnCount = 2
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

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
        .init(
            repeating: .init(
                .flexible(),
                spacing: designMetrics.spacing.inline,
                alignment: .leading
            ),
            count: columnCount
        )
    }

    var columnCount: Int {
        if dynamicTypeSize.isAccessibilitySize {
            return Constants.accessibilityColumnCount
        }
        return Constants.defaultColumnCount
    }
}
