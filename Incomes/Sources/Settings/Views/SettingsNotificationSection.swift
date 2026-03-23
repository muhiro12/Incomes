import SwiftUI

struct SettingsNotificationSection: View {
    @Environment(\.locale)
    private var locale

    @Binding private var notificationSettings: NotificationSettings

    private let model: SettingsScreenModel
    private let authorizationState: NotificationService.AuthorizationState
    private let sendTestNotification: () -> Void
    private let openSystemSettings: () -> Void

    init( // swiftlint:disable:this type_contents_order
        notificationSettings: Binding<NotificationSettings>,
        model: SettingsScreenModel,
        authorizationState: NotificationService.AuthorizationState,
        sendTestNotification: @escaping () -> Void,
        openSystemSettings: @escaping () -> Void
    ) {
        _notificationSettings = notificationSettings
        self.model = model
        self.authorizationState = authorizationState
        self.sendTestNotification = sendTestNotification
        self.openSystemSettings = openSystemSettings
    }

    var body: some View {
        Section("Push notification settings") {
            Toggle("Enable push notifications", isOn: $notificationSettings.isEnabled)
            notificationDetails
            authorizationSection
        }
    }
}

private extension SettingsNotificationSection {
    @ViewBuilder var notificationDetails: some View {
        if model.isNotificationEnabled {
            HStack {
                Text("Notify for amounts over")
                Spacer()
                TextField(
                    "Amount",
                    value: $notificationSettings.thresholdAmount,
                    format: .currency(code: locale.currency?.identifier ?? .empty)
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 120) // swiftlint:disable:this no_magic_numbers
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

    @ViewBuilder var authorizationSection: some View {
        switch model.authorizationPresentation(
            for: authorizationState
        ) {
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

    func notificationFootnote(
        _ text: LocalizedStringKey
    ) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        List {
            SettingsNotificationSection(
                notificationSettings: .constant(.init()),
                model: .init(),
                authorizationState: .authorized,
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
