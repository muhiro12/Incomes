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

    @Environment(NotificationService.self)
    private var notificationService

    @AppStorage(.key(.isSubscribeOn))
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @State private var isAlertPresented = false
}

extension SettingsView: View {
    var body: some View {
        Form {
            Section("Notification") {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Upcoming Changes to the Subscription Plan")
                }
                .font(.headline)
                .foregroundStyle(.red)
                Text(
                    // swiftlint:disable line_length
                    """
                    We would like to inform you that starting August 1st (tentative), the contents of the subscription plan will be updated as follows:

                      1. iCloud synchronization and ad removal will become subscription features.
                      2. Features such as categories and graphs, which were previously part of the subscription, will now be available for free to all users.

                    We greatly appreciate your support and understanding as we make these changes to enhance your experience with our app. Thank you for being a valued member of our community.
                    """
                    // swiftlint:enable line_length
                )
            }
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
        .task {
            notificationService.refresh()
        }
    }
}

#Preview {
    SettingsView()
        .previewNavigation()
        .previewStore()
        .previewContext()
}
