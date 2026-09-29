import SwiftUI

struct DataImportPolicySection: View {
    @Binding var policyChoice: DataImportModel.PolicyChoice

    var body: some View {
        Section {
            Picker("Import method", selection: $policyChoice) {
                Text("Merge")
                    .tag(DataImportModel.PolicyChoice.merge)
                Text("Replace")
                    .tag(DataImportModel.PolicyChoice.replace)
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Import method")
        } footer: {
            switch policyChoice {
            case .merge:
                // swiftlint:disable:next line_length
                Text("Adds items from the file and keeps your items. You decide how to handle items that differ on the same day.")
            case .replace:
                Text("Makes your data match the file. Your items that are not in the file are removed.")
            }
        }
    }
}
