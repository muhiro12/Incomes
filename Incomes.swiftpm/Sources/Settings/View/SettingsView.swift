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
    @Environment(\.dismiss)
    private var dismiss

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

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
                NavigationLink(value: "DuplicatedTags") {
                    Text("Manage Duplicated Tags")
                }
            }
            Section(content: {
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
            }, header: {
                Text("Manage items")
            })
            Section {
                NavigationLink {
                    LicenseView()
                        .navigationTitle(Text("License"))
                } label: {
                    Text("License")
                }
            }
            if DebugView.isDebug {
                NavigationLink {
                    DebugView()
                } label: {
                    Text(String.debugTitle)
                }
            }
        }
        .navigationTitle(Text("Settings"))
        .navigationDestination(for: String.self) { _ in
            DuplicatedTagsView()
                .interactiveDismissDisabled()
        }
        .toolbar {
            ToolbarItem {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: .imageClose)
                        .symbolRenderingMode(.hierarchical)
                }
            }
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
    }
}

#Preview {
    SettingsView()
        .previewNavigation()
        .previewContext()
}
