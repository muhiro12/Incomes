import SwiftUI

struct ChartExpansionIndicator: View {
    private var label: some View {
        Label("Expand", systemImage: "arrow.up.left.and.arrow.down.right")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, ChartExpansionIndicatorMetrics.horizontalPadding)
            .padding(.vertical, ChartExpansionIndicatorMetrics.verticalPadding)
            .foregroundStyle(.secondary)
    }

    var body: some View {
        label
            .incomesGlassSurface(
                cornerRadius: ChartExpansionIndicatorMetrics.cornerRadius,
                isInteractive: true
            )
            .accessibilityHidden(true)
    }
}
