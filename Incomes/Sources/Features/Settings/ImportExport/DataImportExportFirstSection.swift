import SwiftUI

struct DataImportExportFirstSection: View {
    var body: some View {
        Section {
            DataExportButton(title: "Export current data")
        } header: {
            Text("Before importing")
        } footer: {
            Text("Export your current data first so you can restore it if the result is not what you expect.")
        }
    }
}
