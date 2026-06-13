import MHDesign
import SwiftUI

struct CategoryChartEmptyState: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let title: LocalizedStringKey
    let message: LocalizedStringKey

    var body: some View {
        VStack(spacing: designMetrics.spacing.control) {
            Image(systemName: "chart.pie")
                .font(.title2)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: CategoryChartMetrics.sectionHeight
        )
        .accessibilityElement(children: .combine)
    }
}
