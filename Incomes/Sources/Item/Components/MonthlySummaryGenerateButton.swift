import SwiftUI

@available(iOS 26.0, *)
struct MonthlySummaryGenerateButton: View {
    let title: LocalizedStringKey
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .incomesProminentControlStyle()
            .disabled(isDisabled)
    }
}
