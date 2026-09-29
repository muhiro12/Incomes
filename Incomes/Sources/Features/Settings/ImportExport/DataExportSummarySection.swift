import SwiftUI

struct DataExportSummarySection: View {
    let overview: ItemExportOverview

    var body: some View {
        Section {
            LabeledContent("Items") {
                Text(overview.totalCount, format: .number)
            }
            if let firstDate = overview.firstDate,
               let lastDate = overview.lastDate {
                LabeledContent("Period") {
                    Text(firstDate...lastDate)
                }
            }
        } header: {
            Text("Contents")
        } footer: {
            Text("The file can restore all items in Incomes. Keep it private; it includes your financial records.")
        }
    }
}
