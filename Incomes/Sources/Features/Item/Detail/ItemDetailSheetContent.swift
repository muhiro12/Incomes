import SwiftUI

struct ItemDetailSheetContent: View {
    @Binding private var selectedDetent: PresentationDetent

    var body: some View {
        ItemNavigationView()
            .presentationDetents(
                [.medium, .large],
                selection: $selectedDetent
            )
            .incomesSheetPresentation()
    }

    init(selectedDetent: Binding<PresentationDetent>) {
        self._selectedDetent = selectedDetent
    }
}
