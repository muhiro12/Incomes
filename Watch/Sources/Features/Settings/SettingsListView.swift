//
//  SettingsListView.swift
//  Watch
//
//  Created by Codex on 2025/09/15.
//

import MHPreferences
import MHPreferencesUI
import SwiftData
import SwiftUI

struct SettingsListView {}

extension SettingsListView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    WatchItemListView()
                } label: {
                    Label("Items", systemImage: "list.bullet")
                }
            }
            Section {
                NavigationLink {
                    WatchDebugView()
                } label: {
                    Label("Diagnostics", systemImage: "stethoscope")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsListView()
    }
}
