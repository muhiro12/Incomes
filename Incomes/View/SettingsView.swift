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

    @AppStorage(wrappedValue: true, GlobalSettings.modernStyleKey.rawValue)
    private var isModernStyleOn
    @AppStorage(wrappedValue: false, GlobalSettings.iCloudKey.rawValue)
    private var isICloudOn
    @AppStorage(wrappedValue: false, GlobalSettings.subscribeKey.rawValue)
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
        let errorHandler: (Error?) -> Void = { error in
            guard let error = error else {
                return
            }
            print(error)
        }

        let cancelHandler: (Bool) -> Void = { isCancelled in
            guard isCancelled else {
                return
            }
            print(isCancelled)
        }

        self.store.loadProduct { product in
            guard let product = product else {
                print("error")
                return
            }
            self.store.purchase(product: product,
                                errorHandler: errorHandler,
                                cancelHandler: cancelHandler)
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
