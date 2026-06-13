import MHDesign
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormRecognizedTextEditorPlaceholder: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    var body: some View {
        Text("Paste or capture text to extract details.")
            .foregroundStyle(.secondary)
            .padding(.top, designMetrics.layout.surface.compactInsetVertical)
            .padding(.leading, designMetrics.layout.surface.compactInsetHorizontal)
    }
}
