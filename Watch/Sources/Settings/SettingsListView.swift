//
//  SettingsListView.swift
//  Watch
//
//  Created by Codex on 2025/09/15.
//

import SwiftUI

struct SettingsListView {
    @AppStorage(.isSubscribeOn)
    private var isSubscribeOn
    @AppStorage(.isICloudOn)
    private var isICloudOn
    @AppStorage(.isDebugOn)
    private var isDebugOn
    @State private var isTutorialPresented = false
}

extension SettingsListView: View {
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
            Section {
                Button("View Tutorial", systemImage: "questionmark.circle") {
                    isTutorialPresented = true
                }
            }
            // Place debug entry point only at the very bottom of Settings
            if isDebugOn {
                Section {
                    NavigationLink {
                        WatchDebugView()
                    } label: {
                        Label("Debug", systemImage: "flask")
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $isTutorialPresented) {
            NavigationStack {
                WatchTutorialView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsListView()
    }
}
