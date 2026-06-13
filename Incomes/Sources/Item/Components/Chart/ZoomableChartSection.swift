import SwiftUI

struct ZoomableChartSection<Preview: View, Detail: View>: View {
    @Namespace private var transitionNamespace
    @State private var isDetailPresented = false

    private let title: LocalizedStringKey
    private let transitionID: String
    private let allowsExpansion: Bool
    private let preview: () -> Preview
    private let detail: () -> Detail

    var body: some View {
        if allowsExpansion {
            Button {
                isDetailPresented = true
            } label: {
                preview()
                    .matchedTransitionSource(
                        id: transitionID,
                        in: transitionNamespace
                    )
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(title))
            .accessibilityHint(Text("Open expanded chart"))
            .fullScreenCover(isPresented: $isDetailPresented) {
                ZoomableChartDetailPresentation(
                    title: title,
                    transitionID: transitionID,
                    transitionNamespace: transitionNamespace,
                    detail: detail
                )
            }
        } else {
            preview()
        }
    }

    init(
        title: LocalizedStringKey,
        transitionID: String,
        allowsExpansion: Bool = true,
        @ViewBuilder preview: @escaping () -> Preview,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.title = title
        self.transitionID = transitionID
        self.allowsExpansion = allowsExpansion
        self.preview = preview
        self.detail = detail
    }
}
