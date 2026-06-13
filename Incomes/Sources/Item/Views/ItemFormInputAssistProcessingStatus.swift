import MHDesign
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistProcessingStatus: View {
    private enum Constants {
        static let progressTopPaddingRatio: CGFloat = 0.5
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let state: ItemFormInputAssistProcessingState

    var body: some View {
        HStack(alignment: .top, spacing: designMetrics.spacing.control) {
            ProgressView()
                .controlSize(.small)
                .padding(
                    .top,
                    designMetrics.spacing.control * Constants.progressTopPaddingRatio
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: designMetrics.spacing.control) {
                Text(state.title)
                    .font(.body)
                    .fontWeight(.semibold)
                Text(state.message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, designMetrics.layout.surface.compactInsetHorizontal)
        .padding(.vertical, designMetrics.layout.surface.compactInsetVertical)
        .incomesGlassSurface(cornerRadius: designMetrics.cornerRadius.surface)
        .accessibilityElement(children: .combine)
    }
}
