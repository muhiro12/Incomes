import SwiftUI

struct YearlyDuplicationMetadataRow<Content: View>: View {
    let title: LocalizedStringKey
    let content: Content

    var body: some View {
        LabeledContent {
            content
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        } label: {
            Text(title)
        }
        .font(.footnote)
    }

    init(
        _ title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }
}
