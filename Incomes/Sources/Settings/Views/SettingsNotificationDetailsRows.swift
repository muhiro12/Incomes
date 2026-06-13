import SwiftUI

struct SettingsNotificationDetailsRows: View {
    @Binding var notificationSettings: NotificationSettings

    let isNotificationEnabled: Bool
    let sendTestNotification: () -> Void

    var body: some View {
        if isNotificationEnabled {
            SettingsNotificationAmountThresholdRow(
                thresholdAmount: $notificationSettings.thresholdAmount
            )
            Picker("Notify days before", selection: $notificationSettings.daysBeforeDueDate) {
                ForEach(0..<15) { dayOffset in // swiftlint:disable:this no_magic_numbers
                    Text("\(dayOffset) days")
                }
            }
            DatePicker(
                "Notify time",
                selection: $notificationSettings.notifyTime,
                displayedComponents: .hourAndMinute
            )
            Button {
                sendTestNotification()
            } label: {
                Label("Send test notification", systemImage: "bell.badge")
            }
            .accessibilityHint(Text("Sends a test notification with the current settings."))
        }
    }
}
