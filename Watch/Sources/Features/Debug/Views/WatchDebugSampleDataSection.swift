import SwiftUI

struct WatchDebugSampleDataSection: View {
    let isDeleting: Bool
    let deleteDebugData: () -> Void

    var body: some View {
        Section {
            Button(role: .destructive, action: deleteDebugData) {
                if isDeleting {
                    ProgressView()
                } else {
                    Text("Delete debug sample data")
                }
            }
            .disabled(isDeleting)
        } footer: {
            Text("Removes debug sample items and their tags.")
        }
    }
}
