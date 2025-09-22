//
//  SettingsListView.swift
//  Watch
//
//  Created by Codex on 2025/09/15.
//

import SwiftUI

struct SettingsListView {
    @AppStorage(.isDebugOn)
    private var isDebugOn

    @State private var isTutorialPresented = false
}

extension SettingsListView: View {
    var body: some View {
        List {
            Section {
                Button("View Tutorial", systemImage: "questionmark.circle") {
                    isTutorialPresented = true
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
