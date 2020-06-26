//
//  SettingsView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
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
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
