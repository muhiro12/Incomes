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
                Text("iCloud sync is enabled for this session.")
            } else {
                Text("iCloud sync is disabled for this session.")
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
                    if isICloudConfigured {
                        Text("Restart Incomes to turn off iCloud sync. It remains enabled for this session until then.")
                    } else {
                        Text("Restart Incomes to turn on iCloud sync. It remains disabled for this session until then.")
                    }
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
