//
//  SettingsView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SettingsView {
    @Environment(ItemService.self)
    private var itemService
    @Environment(TagService.self)
    private var tagService

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @State private var isDuplicatedTagsPresented = false
    @State private var isAlertPresented = false
}

extension SettingsView: View {
    var body: some View {
        List {
            NotificationSection()
            if isSubscribeOn {
                PremiumSection()
            } else {
                StoreSection()
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
            Section {
                Button {
                    isDuplicatedTagsPresented = true
                } label: {
                    Text("Resolve duplicate tags")
                }
            } header: {
                Text("Manage tags")
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
    }
}

#Preview {
    IncomesPreview { _ in
        SettingsView()
    }
}
