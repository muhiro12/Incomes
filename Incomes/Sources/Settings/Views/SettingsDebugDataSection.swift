import SwiftUI

struct SettingsDebugDataSection: View {
    let hasDebugData: Bool
    let deleteDebugData: () -> Void
    let indicatorSize: CGFloat

    var body: some View {
        if hasDebugData {
            Section {
                Button(role: .destructive, action: deleteDebugData) {
                    Text("Delete debug sample data")
                }
            } header: {
                HStack {
                    Text("Debug data")
                    Circle()
                        .frame(width: indicatorSize)
                        .foregroundStyle(.red)
                }
            } footer: {
                Text("Removes debug sample items and their tags.")
            }
        }
    }
}
