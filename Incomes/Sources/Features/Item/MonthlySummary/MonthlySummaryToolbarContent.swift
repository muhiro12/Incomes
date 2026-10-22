import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryToolbarContent: ToolbarContent {
    let isVisible: Bool
    let generatedSummary: MonthlySummaryResult?
    let isGenerating: Bool
    let errorMessage: String?
    let generateSummary: () -> Void

    var body: some ToolbarContent {
        if isVisible {
            ToolbarItem(placement: placement) {
                MonthlySummaryToolbarButton(
                    generatedSummary: generatedSummary,
                    isGenerating: isGenerating,
                    errorMessage: errorMessage,
                    generateSummary: generateSummary
                )
            }
            ToolbarSpacer(.fixed, placement: placement)
        }
        CreateItemToolbarContent()
    }

    private var placement: ToolbarItemPlacement {
        if #available(iOS 27.0, *) {
            .topBarPinnedTrailing
        } else {
            .topBarTrailing
        }
    }
}
