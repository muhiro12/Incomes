import SwiftUI

struct CopyTextContextMenuButton: View {
    private let title: LocalizedStringKey
    private let systemImage: String
    private let text: String

    var body: some View {
        Button {
            IncomesPasteboardWriter.copy(text)
        } label: {
            Label(title, systemImage: systemImage)
        }
    }

    init(
        _ title: LocalizedStringKey,
        text: String,
        systemImage: String = "doc.on.doc"
    ) {
        self.title = title
        self.systemImage = systemImage
        self.text = text
    }
}
