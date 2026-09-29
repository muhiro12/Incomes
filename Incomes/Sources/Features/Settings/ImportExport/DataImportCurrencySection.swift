import SwiftUI

struct DataImportCurrencySection: View {
    let fileCurrencyCode: String
    @Binding var adoptsFileCurrency: Bool

    var body: some View {
        Section {
            Toggle(isOn: $adoptsFileCurrency) {
                Text("Use \(fileCurrencyCode) as the currency")
            }
        } footer: {
            Text("The file was exported with a different currency setting.")
        }
    }
}
