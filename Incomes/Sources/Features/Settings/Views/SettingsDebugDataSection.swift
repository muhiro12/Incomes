import SwiftUI

struct SettingsDebugDataSection: View {
    let hasDebugData: Bool
    let deleteDebugData: () -> Void

    var body: some View {
        if hasDebugData {
            Section {
                Button(role: .destructive, action: deleteDebugData) {
                    Text("Delete debug sample data")
                }
            } header: {
                HStack {
                    Text("Debug data")
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Debug data, attention needed"))
                .accessibilityAddTraits(.isHeader)
            } footer: {
                Text("Removes debug sample items and their tags.")
            }
        }
    }
}
