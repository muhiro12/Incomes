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
    @Environment(\.presentationMode)
    private var presentationMode

    @AppStorage(UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn = UserDefaults.isSubscribeOn

    @EnvironmentObject private var store: Store

    @State private var isAlertPresented = false
}

extension SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                if isSubscribeOn {
                    PremiumSection()
                } else {
                    StoreSection()
                }
                Section(content: {
                    Button(.localized(.recalculate)) {
                        do {
                            try ItemService(context: context).recalculate()
                        } catch {
                            assertionFailure(error.localizedDescription)
                        }
                    }
                    Button(.localized(.deleteAll), role: .destructive) {
                        isAlertPresented = true
                    }
                }, header: {
                    Text(.localized(.manageItemsHeader))
                })
            }
            .navigationBarTitle(.localized(.settingsTitle))
            .navigationBarItems(trailing: Button(.localized(.done)) {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .alert(.localized(.deleteAllConfirm),
               isPresented: $isAlertPresented) {
            Button(.localized(.delete), role: .destructive) {
                do {
                    try ItemService(context: context).deleteAll()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
            Button(.localized(.cancel), role: .cancel) {}
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    SettingsView()
        .environmentObject(PreviewData.store)
}
