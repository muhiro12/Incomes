import MHDesign
import SwiftUI

struct CategoryChartTotalLabel: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let amount: Decimal

    var body: some View {
        VStack(spacing: designMetrics.spacing.inline) {
            Text("Total")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(amount.asCurrency)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(IncomesTextScaling.minimumScaleFactor)
                .frame(maxWidth: CategoryChartMetrics.totalLabelMaximumWidth)
        }
        .multilineTextAlignment(.center)
    }
}
