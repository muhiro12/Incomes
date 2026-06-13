import SwiftUI

struct ListItemSheetContent: View {
    let route: ListItemRoute

    @Binding private var detents: PresentationDetent

    var body: some View {
        switch route {
        case .detail:
            ItemNavigationView()
                .presentationDetents(
                    [.medium, .large],
                    selection: $detents
                )
                .incomesSheetPresentation()
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
        detents: Binding<PresentationDetent>
    ) {
        self.route = route
        self._detents = detents
    }
}
