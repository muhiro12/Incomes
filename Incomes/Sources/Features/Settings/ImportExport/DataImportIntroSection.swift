import SwiftUI

struct DataImportIntroSection: View {
    let chooseFile: () -> Void

    var body: some View {
        Section {
            Button(action: chooseFile) {
                Label("Choose file", systemImage: "doc.badge.plus")
            }
        } footer: {
            Text("Choose a file exported from Incomes. You can review every change before your data is updated.")
        }
    }
}
