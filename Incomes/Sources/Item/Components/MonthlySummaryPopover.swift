import MHDesign
import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryPopover: View {
    private enum Constants {
        static let popoverIdealWidth: CGFloat = 320
        static let popoverMaximumWidth: CGFloat = 360
        static let popoverMinimumWidth: CGFloat = 280
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let generatedSummary: String?
    let isGenerating: Bool
    let generateSummary: () -> Void

    var body: some View {
        IncomesLiquidGlassControlGroup(spacing: designMetrics.spacing.inline) {
            VStack(alignment: .leading, spacing: designMetrics.spacing.inline) {
                MonthlySummaryHeader(spacing: designMetrics.spacing.inline)
                MonthlySummaryContent(
                    generatedSummary: generatedSummary,
                    isGenerating: isGenerating,
                    spacing: designMetrics.spacing.inline,
                    generateSummary: generateSummary
                )

                Text("Generated on device. Your financial data stays on this device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if generatedSummary != nil {
                    MonthlySummaryGenerateButton(
                        title: "Regenerate Summary",
                        isDisabled: isGenerating,
                        action: generateSummary
                    )
                }
            }
            .frame(
                minWidth: Constants.popoverMinimumWidth,
                idealWidth: Constants.popoverIdealWidth,
                maxWidth: Constants.popoverMaximumWidth,
                alignment: .leading
            )
            .padding()
        }
    }
}
