import MHDesign
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistProcessingStatus: View {
    private enum Constants {
        static let progressTopPaddingRatio: CGFloat = 0.5
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    let state: ItemFormInputAssistProcessingState

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, designMetrics.layout.surface.compactInsetHorizontal)
            .padding(.vertical, designMetrics.layout.surface.compactInsetVertical)
            .incomesGlassSurface(cornerRadius: designMetrics.cornerRadius.surface)
            .accessibilityElement(children: .combine)
    }
}

@available(iOS 26.0, *)
private extension ItemFormInputAssistProcessingStatus {
    @ViewBuilder var content: some View {
        if dynamicTypeSize.isAccessibilitySize {
            verticalLayout
        } else {
            ViewThatFits(in: .horizontal) {
                horizontalLayout
                verticalLayout
            }
        }
    }

    var horizontalLayout: some View {
        HStack(alignment: .top, spacing: designMetrics.spacing.control) {
            topAlignedProgressIndicator
            messageContent
        }
    }

    var verticalLayout: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.control) {
            progressIndicator
            messageContent
        }
    }

    var progressIndicator: some View {
        ProgressView()
            .controlSize(.small)
            .accessibilityHidden(true)
    }

    var topAlignedProgressIndicator: some View {
        progressIndicator
            .padding(
                .top,
                designMetrics.spacing.control * Constants.progressTopPaddingRatio
            )
    }

    var messageContent: some View {
        VStack(alignment: .leading, spacing: designMetrics.spacing.control) {
            Text(state.title)
                .font(.body)
                .fontWeight(.semibold)
            Text(state.message)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
