import MHDesign
import SwiftUI

struct CategoryChartPanel: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics
    @Environment(\.locale)
    private var locale

    let title: LocalizedStringKey
    let segments: [ItemSummaryOperations.ChartSegment]
    let total: Decimal
    let colorScale: [String: Color]
    let fallbackColor: Color
    let emptyStateTitle: LocalizedStringKey
    let emptyStateMessage: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            if segments.isEmpty {
                CategoryChartEmptyState(
                    title: emptyStateTitle,
                    message: emptyStateMessage
                )
            } else {
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
}

private extension CategoryChartPanel {
    var accessibilityValue: Text {
        guard let largestSegment else {
            return Text("No items")
        }
        return Text(verbatim: accessibilityValueParts(largestSegment: largestSegment)
                        .formatted(.list(type: .and).locale(locale)))
    }

    var largestSegment: ItemSummaryOperations.ChartSegment? {
        segments.max { lhs, rhs in
            lhs.value < rhs.value
        }
    }

    func accessibilityValueParts(
        largestSegment: ItemSummaryOperations.ChartSegment
    ) -> [String] {
        [
            String(localized: "Total: \(total.asCurrency)"),
            String(localized: "Largest category: \(largestSegment.title)"),
            String(localized: "Share: \(largestSegment.percentText)"),
            String(localized: "Amount: \(largestSegment.value.asCurrency)")
        ]
    }
}
