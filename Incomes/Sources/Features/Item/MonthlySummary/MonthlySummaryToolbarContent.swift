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
            ToolbarItem(id: "monthlySummary", placement: .topBarTrailing) {
                MonthlySummaryToolbarButton(
                    generatedSummary: generatedSummary,
                    isGenerating: isGenerating,
                    errorMessage: errorMessage,
                    generateSummary: generateSummary
                )
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
        }
        ToolbarItem(id: "monthlySummaryCreateItem", placement: .topBarTrailing) {
            CreateItemButton(presentation: .toolbar)
        }
    }
}
