import SwiftUI

struct DataImportCloudWarningSection: View {
    var body: some View {
        Section {
            Label {
                // swiftlint:disable:next line_length
                Text("iCloud sync is on. This import also changes your other devices. If changes from another device have not arrived yet, items may be duplicated or reappear.")
            } icon: {
                Image(systemName: "exclamationmark.icloud")
                    .foregroundStyle(.orange)
            }
        }
    }
}
