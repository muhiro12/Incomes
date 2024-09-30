//
//  SettingsNavigationView.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/20/24.
//

import SwiftUI
import SwiftUtilities

struct SettingsNavigationView: View {
    @Binding private var tab: MainTab?

    init(selection: Binding<MainTab?> = .constant(nil)) {
        _tab = selection
    }

    var body: some View {
        NavigationStack {
            SettingsListView()
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        MainTabMenu(selection: $tab)
                    }
                }
        }
    }
}

#Preview {
    IncomesPreview { _ in
        SettingsNavigationView()
    }
}
