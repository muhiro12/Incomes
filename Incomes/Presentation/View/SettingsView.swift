//
//  SettingsView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SettingsView {
    @Environment(\.modelContext)
    private var context
    @Environment(\.dismiss)
    private var dismiss

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @State private var isAlertPresented = false
}

extension SettingsView: View {
    var body: some View {
        Form {
            NotificationSection()
            if isSubscribeOn {
                PremiumSection()
            } else {
                StoreSection()
            }
            Section(content: {
                Button("Recalculate") {
                    do {
                        try ItemService(context: context).recalculate()
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                }
                Button("Delete all", role: .destructive) {
                    isAlertPresented = true
                }
            }, header: {
                Text("Manage items")
            })
            if DebugView.isDebug {
                NavigationLink(String.debugTitle) {
                    DebugView()
                }
            }
        }
        .navigationBarTitle("Settings")
        .toolbar {
            ToolbarItem {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: .imageClose)
                        .symbolRenderingMode(.hierarchical)
                })
            }
        }
        .alert("Are you sure you want to delete all items?",
               isPresented: $isAlertPresented) {
            Button("Delete", role: .destructive) {
                do {
                    try ItemService(context: context).deleteAll()
                    try TagService(context: context).deleteAll()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    SettingsView()
        .previewNavigation()
        .previewStore()
        .previewContext()
}
