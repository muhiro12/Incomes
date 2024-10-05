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
    
    @AppStorage(.isDebugOn)
    private var isDebugOn

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
