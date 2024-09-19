//
//  MainTab.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

enum MainTab {
    case home
    case category
    case settings
    case debug
}

extension MainTab {
    @ViewBuilder
    func rootView(selection: Binding<MainTab?>) -> some View {
        switch self {
        case .home:
            HomeNavigationView(selection: selection)
        case .category:
            CategoryNavigationView(selection: selection)
        case .settings:
            SettingsNavigationView(selection: selection)
        case .debug:
            DebugNavigationView(selection: selection)
        }
    }

    @ViewBuilder
    var label: some View {
        switch self {
        case .home:
            Label {
                Text("Home")
            } icon: {
                Image(systemName: "calendar")
            }
        case .category:
            Label {
                Text("Category")
            } icon: {
                Image(systemName: "square.stack.3d.up")
            }
        case .settings:
            Label {
                Text("Settings")
            } icon: {
                Image(systemName: "gear")
            }
        case .debug:
            Label {
                Text("Debug")
            } icon: {
                Image(systemName: "flask")
            }
        }
    }
}

extension MainTab: CaseIterable {}

extension MainTab: Identifiable {
    var id: String {
        .init(describing: self)
    }
}
