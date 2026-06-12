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
            Button {
                isResolveDialogPresented = true
                selectedTags = duplicates
            } label: {
                Text("Resolve All")
            }
            .font(.caption)
            .textCase(nil)
        }
    }
}
