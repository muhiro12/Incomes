//
//  MainTabMenu.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 10/1/24.
//

import SwiftUI

struct MainTabMenu: View {
    @AppStorage(.isDebugOn)
    private var isDebugOn

    @Binding private var tab: MainTab?

    init(selection: Binding<MainTab?> = .constant(nil)) {
        _tab = selection
    }

    private var tabs: [MainTab] {
        if isDebugOn {
            MainTab.allCases
        } else {
            MainTab.allCases.filter {
                $0 != .debug
            }
        }
    }

    var body: some View {
        Menu {
            ForEach(tabs) { tab in
                Button {
                    withAnimation {
                        self.tab = tab
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
}
