import Foundation
import SwiftUI

struct CopyURLContextMenuButton: View {
    private let title: LocalizedStringKey
    private let url: URL

    var body: some View {
        Button {
            IncomesPasteboardWriter.copy(url)
        } label: {
            Label(title, systemImage: "link")
        }
    }

    init(
        _ title: LocalizedStringKey,
        url: URL
    ) {
        self.title = title
        self.url = url
    }
}
