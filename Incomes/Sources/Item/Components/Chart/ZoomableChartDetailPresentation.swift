import SwiftUI

struct ZoomableChartDetailPresentation<Detail: View>: View {
    let title: LocalizedStringKey
    let transitionID: String
    let transitionNamespace: Namespace.ID
    let detail: () -> Detail

    var body: some View {
        NavigationStack {
            detail()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        CloseButton()
                    }
                }
        }
        .navigationTransition(
            .zoom(
                sourceID: transitionID,
                in: transitionNamespace
            )
        )
    }

    init(
        title: LocalizedStringKey,
        transitionID: String,
        transitionNamespace: Namespace.ID,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.title = title
        self.transitionID = transitionID
        self.transitionNamespace = transitionNamespace
        self.detail = detail
    }
}
