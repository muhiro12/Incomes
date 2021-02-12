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
    @State private var purchased = Purchased()

    private let store = Store(productId: EnvironmentParameter.productId,
                              validator: EnvironmentParameter.appleValidator)

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(isOn: $modernStyle.isOn) {
                        Text(LocalizableStrings.modernStyle.localized)
                    }
                }
                Section(footer: purchased.isOn ? nil : Text(LocalizableStrings.subscription.localized)) {
                    if purchased.isOn {
                        Toggle(isOn: $iCloud.isOn) {
                            Text(LocalizableStrings.iCloud.localized)
                        }
                    } else {
                        Button(LocalizableStrings.subscribe.localized) {
                            self.store.purchase()
                        }
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
