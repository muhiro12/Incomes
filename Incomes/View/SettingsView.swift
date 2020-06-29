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

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(isOn: $modernStyle.isOn) {
                        Text(verbatim: .modernStyle)
                    }
                }
                Section(footer: Text(verbatim: .limitedTime)) {
                    Toggle(isOn: $iCloud.isOn) {
                        Text(verbatim: .icloud)
                    }
                }
            }.selectedListStyle()
                .navigationBarTitle(String.settingsTitle)
                .navigationBarItems(trailing: Button(action: dismiss) {
                    Text(verbatim: .done)
                })
        }
    }

    private func dismiss() {
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
