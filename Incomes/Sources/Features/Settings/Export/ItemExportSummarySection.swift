import SwiftUI

struct ItemExportSummarySection: View {
    let selectedCount: Int
    let totalCount: Int

    var body: some View {
        Section {
            LabeledContent("Selected items") {
                Text(selectedCount, format: .number)
            }
            LabeledContent("All items") {
                Text(totalCount, format: .number)
            }
        } header: {
            Text("Export scope")
        } footer: {
            Text("CSV is for spreadsheets. It cannot restore your data.")
        }
    }
}
