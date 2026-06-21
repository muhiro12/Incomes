import MHDesign
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormRecognizedTextEditorBorder: View {
    private enum Constants {
        static let lineWidth: CGFloat = 1
        static let opacity = 0.18
    }

    @Environment(\.mhDesignMetrics)
    private var designMetrics

    var body: some View {
        RoundedRectangle(
            cornerRadius: designMetrics.cornerRadius.surface,
            style: .continuous
        )
        .stroke(
            Color.secondary.opacity(Constants.opacity),
            lineWidth: Constants.lineWidth
        )
    }
}
