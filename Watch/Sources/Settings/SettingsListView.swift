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
                Button {
                    guard !isReloading else { return }
                    isReloading = true
                    WatchDataSyncer.syncRecentMonths(context: context) {
                        DispatchQueue.main.async { isReloading = false }
                    }
                } label: {
                    if isReloading {
                        ProgressView()
                    } else {
                        Text("Reload")
                    }
                }
                .disabled(isReloading)
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
