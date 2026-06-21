import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryToolbarContent: ToolbarContent {
    let isVisible: Bool
    let generatedSummary: String?
    let isGenerating: Bool
    @Binding var isPopoverPresented: Bool
    let generateInitialSummary: () -> Void
    let generateSummary: () -> Void

    var body: some ToolbarContent {
        if isVisible {
            ToolbarItem(placement: .topBarTrailing) {
                MonthlySummaryToolbarButton(
                    generatedSummary: generatedSummary,
                    isGenerating: isGenerating,
                    isPopoverPresented: $isPopoverPresented,
                    generateInitialSummary: generateInitialSummary,
                    generateSummary: generateSummary
                )
            }
        }
    }
}
