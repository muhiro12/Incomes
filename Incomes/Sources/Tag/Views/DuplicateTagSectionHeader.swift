import SwiftUI

struct DuplicateTagSectionHeader: View {
    let title: LocalizedStringKey
    let duplicates: [Tag]

    @Binding var selectedTags: [Tag]
    @Binding var isResolveDialogPresented: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button("Resolve All", role: .destructive, action: presentResolveAllDialog)
                .font(.caption)
                .textCase(nil)
        }
    }
}

private extension DuplicateTagSectionHeader {
    func presentResolveAllDialog() {
        isResolveDialogPresented = true
        selectedTags = duplicates
    }
}
