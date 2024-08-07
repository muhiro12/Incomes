//
//  SettingsView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI
import SwiftUtilities

struct SettingsView {
    @Environment(ItemService.self)
    private var itemService
    @Environment(TagService.self)
    private var tagService

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn
    @AppStorage(.key(.isICloudOn))
    private var isICloudOn = UserDefaults.isICloudOn
    @AppStorage(.key(.isMaskAppOn))
    private var isMaskAppOn = UserDefaults.isMaskAppOn

    @State private var isDuplicatedTagsPresented = false
    @State private var isAlertPresented = false
}

extension SettingsView: View {
    var body: some View {
        List {
            NotificationSection()
            if isSubscribeOn {
                Toggle(isOn: $isICloudOn) {
                    Text("iCloud On")
                }
            } else {
                StoreSection()
            }
            Section {
                Toggle(isOn: $isMaskAppOn) {
                    Text("Mask the app")
                }
            }
            Section {
                Button {
                    do {
                        try itemService.recalculate()
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                } label: {
                    Text("Recalculate")
                }
                Button(role: .destructive) {
                    isAlertPresented = true
                } label: {
                    Text("Delete all")
                }
            } header: {
                Text("Manage items")
            }
            if tagService.hasDuplicates {
                Section {
                    Button {
                        isDuplicatedTagsPresented = true
                    } label: {
                        Text("Resolve duplicate tags")
                    }
                } header: {
                    HStack {
                        Text("Manage tags")
                        Circle()
                            .frame(width: .iconS)
                            .foregroundStyle(.orange)
                    }
                }
            }
            Section {
                NavigationLink(path: .license) {
                    Text("License")
                }
            }
            if DebugView.isDebug {
                NavigationLink(path: .debug) {
                    Text(String.debugTitle)
                }
            }
        }
        .fullScreenCover(isPresented: $isDuplicatedTagsPresented) {
            DuplicateTagsNavigationView()
        }
        .alert(Text("Are you sure you want to delete all items?"),
               isPresented: $isAlertPresented) {
            Button(role: .destructive) {
                do {
                    try itemService.deleteAll()
                    try tagService.deleteAll()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
            } label: {
                Text("Cancel")
            }
        }
        .toolbar {
            ToolbarItem {
                CloseButton()
            }
        }
        .navigationTitle(Text("Settings"))
        .task {
            try? tagService.updateHasDuplicates()
        }
    }
}

#Preview {
    IncomesPreview { _ in
        SettingsView()
    }
}
