import SwiftUI

struct SettingsICloudSection: View {
    let isSubscribeOn: Bool
    @Binding var isICloudOn: Bool
    let isICloudConfigured: Bool

    var body: some View {
        Section {
            Toggle("iCloud Sync", isOn: $isICloudOn)
                .disabled(!isSubscribeOn && !isICloudOn)
            if isICloudConfigured {
                Text("This session uses iCloud sync.")
            } else {
                Text("This session saves on this device.")
            }
        } footer: {
            VStack(alignment: .leading) {
                Text(
                    """
                    iCloud sync requires a subscription. Your choice is kept when your subscription ends and used \
                    again after renewal. Changes take effect the next time Incomes launches.
                    """
                )
                if (isSubscribeOn && isICloudOn) != isICloudConfigured {
                    Text(
                        "Restart Incomes to apply changes. The current iCloud sync setting remains active until then."
                    )
                }
            }
        }
    }
}

#Preview("Lapsed, current iCloud session") {
    @Previewable @State var isICloudOn = true
    NavigationStack {
        List {
            SettingsICloudSection(isSubscribeOn: false, isICloudOn: $isICloudOn, isICloudConfigured: true)
        }
        .navigationTitle("Settings")
    }
}

#Preview("Renewed, next-launch sync") {
    @Previewable @State var isICloudOn = true
    NavigationStack {
        List {
            SettingsICloudSection(isSubscribeOn: true, isICloudOn: $isICloudOn, isICloudConfigured: false)
        }
        .navigationTitle("Settings")
    }
}

#Preview("Inactive, explicit off") {
    @Previewable @State var isICloudOn = false
    NavigationStack {
        List {
            SettingsICloudSection(isSubscribeOn: false, isICloudOn: $isICloudOn, isICloudConfigured: false)
        }
        .navigationTitle("Settings")
    }
}
