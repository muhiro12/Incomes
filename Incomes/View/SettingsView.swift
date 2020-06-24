//
//  SettingsView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    class ICloudWrapper: ObservableObject {
        var isOn = GlobalSettings.iCloud {
            didSet {
                GlobalSettings.iCloud = isOn
            }
        }
    }

    @State private var iCloud = ICloudWrapper()

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text(verbatim: .limitedTime)) {
                    Toggle(isOn: $iCloud.isOn) {
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
