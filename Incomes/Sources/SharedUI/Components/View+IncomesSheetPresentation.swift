import SwiftUI

private enum IncomesSheetPresentation {
    static let cornerRadius: CGFloat = 24
}

extension View {
    @ViewBuilder
    func incomesSheetPresentation() -> some View {
        if #available(iOS 26.0, *) {
            presentationDragIndicator(.visible)
        } else {
            presentationDragIndicator(.visible)
                .presentationCornerRadius(IncomesSheetPresentation.cornerRadius)
        }
    }
}
