import SwiftData
import SwiftUI

struct DataExportView: View {
    @Query(.items(.all))
    private var items: [Item]

    var body: some View {
        let overview = ItemExportOperations.overview(items: items)

        Form {
            DataExportSummarySection(overview: overview)
            Section {
                DataExportButton(title: "Export")
                if overview.totalCount == 0 {
                    Text("No items to export.")
                }
            }
        }
        .navigationTitle("Export data")
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        DataExportView()
    }
}
