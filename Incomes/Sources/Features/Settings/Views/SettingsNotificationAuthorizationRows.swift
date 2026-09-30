import SwiftUI

/// Actionable rows for the current notification permission.
struct SettingsNotificationAuthorizationRows: View {
    let authorizationPresentation: SettingsScreenModel.AuthorizationPresentation
    let openSystemSettings: () -> Void

    var body: some View {
        if authorizationPresentation == .denied {
            Button {
                openSystemSettings()
            } label: {
                Label("Open System Settings", systemImage: "gearshape")
            }
            .accessibilityHint(Text("Opens iOS Settings to change notification permission."))
        }
    }
}
