//
//  SettingsView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    @AppStorage(wrappedValue: true, UserDefaults.Key.isModernStyleOn.rawValue)
    private var isModernStyleOn
    @AppStorage(wrappedValue: false, UserDefaults.Key.isLockAppOn.rawValue)
    private var isLockAppOn
    @AppStorage(wrappedValue: false, UserDefaults.Key.isICloudOn.rawValue)
    private var isICloudOn
    @AppStorage(wrappedValue: false, UserDefaults.Key.isSubscribeOn.rawValue)
    private var isSubscribeOn

    private let store = Store.shared

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(isOn: $isModernStyleOn) {
                        Text(.localized(.modernStyle))
                    }
                }
                Section {
                    Toggle(isOn: $isLockAppOn) {
                        Text(.localized(.lockApp))
                    }
                }
                if isSubscribeOn {
                    Section {
                        Toggle(isOn: $isICloudOn) {
                            Text(.localized(.iCloud))
                        }
                    }
                } else {
                    Section(header: Text(.localized(.subscriptionTitle)),
                            footer: Text(.localized(.subscriptionDescription))) {
                        Button(.localized(.subscribe), action: purchase)
                        Button(.localized(.restore), action: restore)
                    }
                }
            }.selectedListStyle()
            .navigationBarTitle(.localized(.settingsTitle))
            .navigationBarItems(trailing: Button(action: dismiss) {
                Text(.localized(.done))
                    .bold()
            })
        }.navigationViewStyle(StackNavigationViewStyle())
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
