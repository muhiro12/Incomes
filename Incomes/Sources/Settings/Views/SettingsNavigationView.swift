//
//  SettingsNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI

struct SettingsNavigationView: View {
    var body: some View {
        NavigationStack {
            SettingsListView()
        }
    }
}

#Preview {
    IncomesPreview { _ in
        SettingsNavigationView()
    }
}
