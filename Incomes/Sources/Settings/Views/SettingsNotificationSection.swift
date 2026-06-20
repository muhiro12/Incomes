import MHDesign
import SwiftUI

struct SettingsNotificationSection: View {
    @Binding private var notificationSettings: NotificationSettings

    private let isNotificationEnabled: Bool
    private let authorizationPresentation: SettingsScreenModel.AuthorizationPresentation
    private let sendTestNotification: () -> Void
    private let openSystemSettings: () -> Void

    init(
        notificationSettings: Binding<NotificationSettings>,
        isNotificationEnabled: Bool,
        authorizationPresentation: SettingsScreenModel.AuthorizationPresentation,
        sendTestNotification: @escaping () -> Void,
        openSystemSettings: @escaping () -> Void
    ) {
        _notificationSettings = notificationSettings
        self.isNotificationEnabled = isNotificationEnabled
        self.authorizationPresentation = authorizationPresentation
        self.sendTestNotification = sendTestNotification
        self.openSystemSettings = openSystemSettings
    }
}

extension SettingsNotificationSection {
    @ViewBuilder var body: some View {
        Section("Push notification settings") {
            Toggle("Enable push notifications", isOn: $notificationSettings.isEnabled)
            SettingsNotificationDetailsRows(
                notificationSettings: $notificationSettings,
                isNotificationEnabled: isNotificationEnabled,
                sendTestNotification: sendTestNotification
            )
            SettingsNotificationAuthorizationRows(
                authorizationPresentation: authorizationPresentation,
                openSystemSettings: openSystemSettings
            )
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        List {
            SettingsNotificationSection(
                notificationSettings: .constant(.init()),
                isNotificationEnabled: true,
                authorizationPresentation: .authorized,
                sendTestNotification: {
                    // no-op
                },
                openSystemSettings: {
                    // no-op
                }
            )
        }
    }
}
