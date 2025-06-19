//
//  MainTabMenu.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/1/24.
//

import SwiftUI

struct MainTabMenu: View {
    @Environment(\.mainTab)
    private var mainTab

    var body: some View {
        Menu {
            ForEach(MainTab.allCases) { tab in
                Button {
                    Haptic.selectionChanged.impact()
                    withAnimation {
                        mainTab.wrappedValue = tab
                    }
                } label: {
                    tab.label
                }
            }
        } label: {
            Label {
                Text("Menu")
            } icon: {
                Image(systemName: "list.bullet")
            }
        }
    }
}

#Preview {
    MainTabMenu()
        .environment(\.mainTab, .constant(.home))
}
