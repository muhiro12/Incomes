import SwiftUI

extension View {
    @ViewBuilder
    func incomesProminentControlStyle() -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glassProminent)
        } else {
            buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
        }
    }

    @ViewBuilder
    func incomesSecondaryControlStyle() -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glass)
        } else {
            buttonStyle(.bordered)
        }
    }
}
