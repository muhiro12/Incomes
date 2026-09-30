import SwiftUI

/// Explains what the current notification permission means for reminders.
struct SettingsNotificationAuthorizationFooter: View {
    let authorizationPresentation: SettingsScreenModel.AuthorizationPresentation

    var body: some View {
        switch authorizationPresentation {
        case .authorized:
            Text("Notifications are enabled and will follow your in-app schedule.")
        case .denied:
            Text("Notifications are currently denied in iOS Settings.")
        case .notDetermined:
            Text("Notification permission will be requested when reminders are registered.")
        }
    }
}
