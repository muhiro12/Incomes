//
//  SettingsNavigationView.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/25.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SettingsNavigationView: View {
    var body: some View {
        NavigationStack {
            SettingsView()
        }
    }
}

#Preview {
    SettingsNavigationView()
        .previewStore()
}
