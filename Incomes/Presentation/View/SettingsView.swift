//
//  SettingsView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext)
    private var viewContext
    @Environment(\.presentationMode)
    var presentationMode

    @AppStorage(wrappedValue: false, UserDefaults.Key.isLockAppOn.rawValue)
    private var isLockAppOn
    @AppStorage(wrappedValue: false, UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn

    @State
    private var isAlertPresented = false

    private let store = Store.shared

    var body: some View {
        NavigationView {
            Form {
                if isSubscribeOn {
                    Section {
                        Toggle(isOn: $isLockAppOn) {
                            Text(.localized(.lockApp))
                        }
                    }
                } else if false {
                    // TODO: Remove false
                    Section(content: {
                        Button(.localized(.subscribe), action: purchase)
                        Button(.localized(.restore), action: restore)
                    }, header: {
                        Text(.localized(.subscriptionHeader))
                    }, footer: {
                        Text(.localized(.subscriptionFooter))
                    })
                }
                Section(content: {
                    Button(.localized(.recalculate)) {
                        do {
                            try ItemService(context: viewContext).recalculate()
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
            }.navigationBarTitle(.localized(.settingsTitle))
            .navigationBarItems(trailing: Button(action: dismiss) {
                Text(.localized(.done))
                    .bold()
            })
        }.navigationViewStyle(StackNavigationViewStyle())
        .alert(.localized(.deleteAllConfirm),
               isPresented: $isAlertPresented) {
            Button(.localized(.delete), role: .destructive) {
                do {
                    try ItemService(context: viewContext).deleteAll()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
            Button(.localized(.cancel), role: .cancel) {}
        }
    }
}

// MARK: - private

private extension SettingsView {
    func purchase() {
        Task {
            do {
                guard let product = try await store.product() else {
                    return
                }
                _ = try await store.purchase(product: product)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    func restore() {
        store.restore()
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
