import SwiftUI

struct CategoryRenameNameSection: View {
    @Binding var draftName: String

    var body: some View {
        Section {
            TextField("Name", text: $draftName)
        } header: {
            Text("Name")
        }
    }
}
