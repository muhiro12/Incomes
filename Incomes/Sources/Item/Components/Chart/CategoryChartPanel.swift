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
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(title))
            .accessibilityValue(accessibilityValue)
            CategoryChartLegend(
                segments: segments,
                colorScale: colorScale
            )
        }
    }
}

private extension CategoryChartPanel {
    var accessibilityValue: Text {
        guard let largestSegment = segments.max(by: { lhs, rhs in
            lhs.value < rhs.value
        }) else {
            return Text("Total: \(total.asCurrency), No categories")
        }
        return Text(
            """
            Total: \(total.asCurrency), \
            Largest category: \(largestSegment.title), \
            \(largestSegment.percentText), \
            \(largestSegment.value.asCurrency)
            """
        )
    }
}
