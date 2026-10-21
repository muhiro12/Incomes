import MHPlatform
import SwiftUI

/// Keeps the editing exception behind an explanation and a separate confirmation.
struct RemoteUpdateEditingSettingsView: View {
    @AppStorage(\.allowsUnverifiedEditing)
    private var allowsUnverifiedEditing: Bool
    @State private var isConfirmingEditing = false

    var body: some View {
        Form {
            Section("When this helps") {
                Text("Keep recording income and expenses when you cannot connect to the internet for a long time.")
                Text("Incomes normally pauses editing when it cannot confirm whether an update is needed.")
            }
            Section {
                Text(
                    """
                    If an important update is needed but cannot be checked, even one addition, edit, or deletion \
                    may make your records incorrect or unusable. Updating later may not restore them.
                    """
                )
                Text("The developer does not provide repair or recovery for data problems caused by this setting.")
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
                Even one change could cause data problems that an update cannot repair. \
                The developer does not provide data repair or recovery for this setting.
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
