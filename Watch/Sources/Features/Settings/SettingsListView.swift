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

    #if DEBUG
    @State private var showsScreenshotItems = false
    #endif
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
        #if DEBUG
        .navigationDestination(isPresented: $showsScreenshotItems) {
            WatchItemListView()
        }
        .task {
            guard WatchScreenshotSupport.isEnabled,
                  WatchScreenshotSupport.presentsItems else {
                return
            }
            showsScreenshotItems = true
        }
        #endif
    }
}

#Preview {
    NavigationStack {
        SettingsListView()
    }
}
