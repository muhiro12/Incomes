import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryContent: View {
    let generatedSummary: String?
    let isGenerating: Bool
    let spacing: CGFloat
    let generateSummary: () -> Void

    var body: some View {
        if let generatedSummary {
            Text(generatedSummary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        } else if isGenerating {
            MonthlySummaryGeneratingContent(spacing: spacing)
        } else {
            MonthlySummaryGenerateButton(
                title: "Generate Summary",
                isDisabled: false,
                action: generateSummary
            )
        }
    }
}
