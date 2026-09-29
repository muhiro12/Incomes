import SwiftUI

struct DataImportFileSection: View {
    let contents: IncomesFileContents
    let overview: ItemExportOverview

    var body: some View {
        Section {
            LabeledContent("Exported") {
                Text(contents.exportedAt, format: .dateTime.year().month().day().hour().minute())
            }
            LabeledContent("Items") {
                Text(overview.totalCount, format: .number)
            }
            if let firstDate = overview.firstDate,
               let lastDate = overview.lastDate {
                LabeledContent("Period") {
                    Text((firstDate..<lastDate).formatted(.interval.year().month().day()))
                }
            }
            if let currencyCode = contents.currencyCode {
                LabeledContent("Currency") {
                    Text(currencyCode)
                }
            }
        } header: {
            Text("File")
        }
    }
}
