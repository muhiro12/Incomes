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
            HStack(spacing: spacing) {
                ProgressView()
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            MonthlySummaryGenerateButton(
                title: "Generate Summary",
                isDisabled: false,
                action: generateSummary
            )
        }
    }
}
