import SwiftUI

private enum IncomesSheetPresentation {
    static let cornerRadius: CGFloat = 24
}

extension View {
    func incomesSheetPresentation() -> some View {
        presentationDragIndicator(.visible)
            .presentationCornerRadius(IncomesSheetPresentation.cornerRadius)
    }
}
