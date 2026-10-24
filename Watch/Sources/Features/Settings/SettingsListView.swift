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

struct SettingsListView {
    @AppStorage(\.isDebugOn)
    private var isDebugOn
}

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
    }
}

#Preview {
    NavigationStack {
        SettingsListView()
    }
}
