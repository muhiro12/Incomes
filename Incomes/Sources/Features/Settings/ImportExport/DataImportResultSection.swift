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
            if result.changedLedgerCount > 0 {
                LabeledContent("Updated accounts") {
                    Text(result.changedLedgerCount, format: .number)
                }
            }
            Button("Import another file", action: chooseAnotherFile)
        } header: {
            Text("Import complete")
        }
    }
}
