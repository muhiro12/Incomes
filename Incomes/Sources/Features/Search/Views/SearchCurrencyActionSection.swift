import MHDesign
import SwiftUI

struct SearchCurrencyActionSection: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let isVisible: Bool
    let isEnabled: Bool
    let applySearch: () -> Void

    var body: some View {
        if isVisible {
            Section {
                if #available(iOS 26.0, *) {
                    actionButton
                        .listRowInsets(actionRowInsets)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    actionButton
                }
            }
        }
    }
}

private extension SearchCurrencyActionSection {
    var actionButton: some View {
        SearchCurrencyActionButton(
            isEnabled: isEnabled,
            applySearch: applySearch
        )
    }

    var actionRowInsets: EdgeInsets {
        .init(
            top: designMetrics.layout.surface.compactInsetVertical,
            leading: designMetrics.layout.surface.compactInsetHorizontal,
            bottom: designMetrics.layout.surface.compactInsetVertical,
            trailing: designMetrics.layout.surface.compactInsetHorizontal
        )
    }
}
