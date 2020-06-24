//
//  SettingsView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @State private var iCloud = false

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text(verbatim: .limitedTime)) {
                    Toggle(isOn: $iCloud) {
                        Text(verbatim: .icloud)
                    }
                }
            }.groupedListStyle()
                .navigationBarTitle(String.settingsTitle)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
