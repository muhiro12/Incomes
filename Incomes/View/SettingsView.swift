//
//  SettingsView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @State private var isOn = false

    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: $isOn) {
                    Text(String.settings)
                }
            }.groupedListStyle()
                .navigationBarTitle(String.settings)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
