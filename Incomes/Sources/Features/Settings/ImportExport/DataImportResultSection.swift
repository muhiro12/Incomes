import SwiftUI

struct DataImportResultSection: View {
    let result: ItemImportResult
    let chooseAnotherFile: () -> Void

    var body: some View {
        Section {
            LabeledContent("Added items") {
                Text(result.addedCount, format: .number)
            }
            LabeledContent("Removed items") {
                Text(result.removedCount, format: .number)
            }
            Button("Import another file", action: chooseAnotherFile)
        } header: {
            Text("Import complete")
        }
    }
}
