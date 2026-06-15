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
        if #available(iOS 26.0, *) {
            label
                .incomesGlassEffect(
                    cornerRadius: ChartExpansionIndicatorMetrics.cornerRadius,
                    isInteractive: true
                )
                .accessibilityHidden(true)
        } else {
            label
                .incomesGlassSurface(cornerRadius: ChartExpansionIndicatorMetrics.cornerRadius)
                .accessibilityHidden(true)
        }
    }
}
