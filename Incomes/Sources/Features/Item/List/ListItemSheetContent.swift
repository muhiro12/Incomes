import SwiftUI

struct ListItemSheetContent: View {
    let route: ListItemRoute

    @Binding private var detailPresentationDetent: PresentationDetent

    var body: some View {
        switch route {
        case .detail:
            ItemDetailSheetContent(selectedDetent: $detailPresentationDetent)
        case .edit:
            ItemFormNavigationView(mode: .edit)
                .incomesSheetPresentation()
        case .duplicate:
            ItemFormNavigationView(mode: .create)
                .incomesSheetPresentation()
        }
    }

    init(
        route: ListItemRoute,
        detailPresentationDetent: Binding<PresentationDetent>
    ) {
        self.route = route
        self._detailPresentationDetent = detailPresentationDetent
    }
}
