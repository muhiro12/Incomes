import MHDesign
import SwiftUI

struct SettingsNotificationDetailsRows: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var notificationSettings: NotificationSettings

    let isNotificationEnabled: Bool
    let sendTestNotification: () -> Void

    var body: some View {
        if isNotificationEnabled {
            HStack {
                Text("Notify for amounts over")
                Spacer()
                TextField(
                    "Amount",
                    value: $notificationSettings.thresholdAmount,
                    format: .currency(code: locale.currency?.identifier ?? "")
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: designMetrics.layout.readableContentWidth)
            }
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
            Button("Send test notification") {
                sendTestNotification()
            }
        }
    }
}
