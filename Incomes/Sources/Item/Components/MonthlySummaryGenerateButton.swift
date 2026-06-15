import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryGenerateButton: View {
    let title: LocalizedStringKey
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "sparkles")
        }
        .incomesProminentControlStyle()
        .disabled(isDisabled)
    }
}
