import SwiftUI

struct SettingsNotificationDetailsRows: View {
    private enum Constants {
        static let dayOffsetRange = 0..<15
    }

    @Binding var notificationSettings: NotificationSettings

    let isNotificationEnabled: Bool
    let sendTestNotification: () -> Void

    var body: some View {
        if isNotificationEnabled {
            SettingsNotificationAmountThresholdRow(
                thresholdAmount: $notificationSettings.thresholdAmount
            )
            Picker("Notify days before", selection: $notificationSettings.daysBeforeDueDate) {
                ForEach(Constants.dayOffsetRange, id: \.self) { dayOffset in
                    SettingsNotificationDayOffsetLabel(dayOffset: dayOffset)
                        .tag(dayOffset)
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
