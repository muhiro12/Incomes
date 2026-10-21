import MHPlatform
import SwiftUI

/// Keeps the editing exception behind an explanation and a separate confirmation.
struct RemoteUpdateEditingSettingsView: View {
    @AppStorage(\.allowsUnverifiedEditing)
    private var allowsUnverifiedEditing: Bool
    @State private var isConfirmingEditing = false

    var body: some View {
        Form {
            Section {
                Text("Keep recording income and expenses when you cannot connect to the internet for a long time.")
            } header: {
                Text("When this helps")
            } footer: {
                Text("Incomes normally pauses editing when it cannot confirm whether an update is needed.")
            }
            Section {
                Text(
                    """
                    If an important update is missed, even one change may make records incorrect or unusable. \
                    Updating later may not fix this, and the developer cannot restore the affected records for you.
                    """
                )
            } header: {
                Label("Data risks", systemImage: "exclamationmark.triangle")
            }
            Section {
                Toggle("Allow editing when updates cannot be checked", isOn: editingBinding)
            } footer: {
                Text(
                    """
                    When Incomes knows an update is required, editing stays paused. \
                    This setting is saved only on this device. iCloud sync stays unchanged.
                    """
                )
            }
        }
        .navigationTitle("Offline Editing")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Allow editing without checking for updates?", isPresented: $isConfirmingEditing) {
            Button("Cancel", role: .cancel) {
                // Permission remains off until the explicit confirmation below.
            }
            Button("Allow Editing") {
                allowsUnverifiedEditing = true
            }
        } message: {
            Text(
                """
                Even one change may cause data problems that cannot be repaired. \
                Allow editing without checking for updates?
                """
            )
        }
    }
}

private extension RemoteUpdateEditingSettingsView {
    var editingBinding: Binding<Bool> {
        .init(
            get: { allowsUnverifiedEditing },
            set: { isAllowed in
                if isAllowed {
                    isConfirmingEditing = true
                } else {
                    allowsUnverifiedEditing = false
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        RemoteUpdateEditingSettingsView()
    }
}
