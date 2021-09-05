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

    @State private var modernStyle = ModernStyle()
    @State private var iCloud = ICloud()
    @State private var subscribe = Subscribe()

    private let store = Store.shared

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(isOn: $modernStyle.isOn) {
                        Text(LocalizableStrings.modernStyle.localized)
                    }
                }
                Section(footer: subscribe.isOn ? nil : Text(LocalizableStrings.subscription.localized)) {
                    if subscribe.isOn {
                        Toggle(isOn: $iCloud.isOn) {
                            Text(LocalizableStrings.iCloud.localized)
                        }
                    } else {
                        Button(LocalizableStrings.subscribe.localized, action: purchase)
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
