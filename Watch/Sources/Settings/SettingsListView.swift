//
//  SettingsListView.swift
//  Watch
//
//  Created by Codex on 2025/09/15.
//

import IncomesLibrary
import SwiftUI

struct SettingsListView: View {
    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(isSubscribeOn ? "Active" : "Inactive")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Subscription")
            } footer: {
                Text("Manage your subscription in the iPhone app's Settings. Purchases are not available on Apple Watch.")
            }
            Section {
                Toggle(isOn: $isICloudOn) {
                    Text("iCloud On")
                }
                .disabled(!isSubscribeOn)
            } header: {
                Text("iCloud")
            } footer: {
                Text("When enabled, data syncs with the iPhone app via iCloud. A full effect may require restarting the app.")
            }
        }
        .navigationTitle(Text("Settings"))
    }
}

#Preview {
    NavigationStack {
        SettingsListView()
    }
}
