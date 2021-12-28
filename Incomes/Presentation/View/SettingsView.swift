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
                        Text(LocalizableStrings.modernStyle.localized)
                    }
                }
                Section {
                    Toggle(isOn: $isLockAppOn) {
                        Text(LocalizableStrings.lockApp.localized)
                    }
                }
                if isSubscribeOn {
                    Section {
                        Toggle(isOn: $isICloudOn) {
                            Text(LocalizableStrings.iCloud.localized)
                        }
                    }
                } else {
                    Section(header: Text(LocalizableStrings.subscriptionTitle.localized),
                            footer: Text(LocalizableStrings.subscriptionDescription.localized)) {
                        Button(LocalizableStrings.subscribe.localized, action: purchase)
                        Button(LocalizableStrings.restore.localized, action: restore)
                    }
                }
            }.selectedListStyle()
            .navigationBarTitle(LocalizableStrings.settingsTitle.localized)
            .navigationBarItems(trailing: Button(action: dismiss) {
                Text(LocalizableStrings.done.localized)
                    .bold()
            })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - private

private extension SettingsView {
    func purchase() {
        Task {
            guard let product = try await store.product() else {
                return
            }
            _ = try await store.purchase(product: product)
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
