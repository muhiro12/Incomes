import SwiftUI

struct WatchDebugSampleDataSection: View {
    let deleteDebugData: () -> Void

    var body: some View {
        Section {
            Button(role: .destructive, action: deleteDebugData) {
                Text("Delete debug sample data")
            }
        } footer: {
            Text("Removes debug sample items and their tags.")
        }
    }
}
