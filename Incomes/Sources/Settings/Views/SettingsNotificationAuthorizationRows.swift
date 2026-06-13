import SwiftUI

struct SettingsNotificationAuthorizationRows: View {
    let authorizationPresentation: SettingsScreenModel.AuthorizationPresentation
    let openSystemSettings: () -> Void

    var body: some View {
        switch authorizationPresentation {
        case .authorized:
            notificationFootnote(
                "Notifications are enabled and will follow your in-app schedule."
            )
        case .denied:
            Button("Open System Settings") {
                openSystemSettings()
            }
            notificationFootnote(
                "Notifications are currently denied in iOS Settings."
            )
        case .notDetermined:
            notificationFootnote(
                "Notification permission will be requested when reminders are registered."
            )
        }
    }
}

private extension SettingsNotificationAuthorizationRows {
    func notificationFootnote(
        _ text: LocalizedStringKey
    ) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
