//
//  SettingsListView.swift
//  Watch
//
//  Created by Codex on 2025/09/15.
//

import SwiftData
import SwiftUI

struct SettingsListView {
    @Environment(\.modelContext)
    private var context
    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var isTutorialPresented = false
    @State private var isReloading = false
}

extension SettingsListView: View {
    var body: some View {
        List {
            Section {
                Button("View Tutorial", systemImage: "questionmark.circle") {
                    isTutorialPresented = true
                }
            }
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
