import MHDesign
import SwiftUI

@available(iOS 26.0, *)
struct ItemFormInputAssistProcessingSection: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let state: ItemFormInputAssistProcessingState

    var body: some View {
        Section {
            ItemFormInputAssistProcessingStatus(state: state)
                .listRowInsets(rowInsets)
        }
    }
}

@available(iOS 26.0, *)
private extension ItemFormInputAssistProcessingSection {
    var rowInsets: EdgeInsets {
        .init(
            top: designMetrics.layout.surface.compactInsetVertical,
            leading: designMetrics.layout.surface.compactInsetHorizontal,
            bottom: designMetrics.layout.surface.compactInsetVertical,
            trailing: designMetrics.layout.surface.compactInsetHorizontal
        )
    }
}
