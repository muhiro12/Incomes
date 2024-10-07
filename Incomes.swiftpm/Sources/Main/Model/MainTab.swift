//
//  MainTab.swift
//  Incomes Playgrounds
//
//  Created by Hiromu Nakano on 9/19/24.
//

import SwiftUI

enum MainTab {
    case home
    case content
    case category
    case settings
    case debug
}

extension MainTab {
    @ViewBuilder
    var rootView: some View {
        Group {
            switch self {
            case .home:
                HomeNavigationView()
            case .content:
                TagNavigationView(tagType: .content)
            case .category:
                TagNavigationView(tagType: .category)
            case .settings:
                SettingsNavigationView()
            case .debug:
                DebugNavigationView()
            }
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
        case .content:
            Label {
                Text("Content")
            } icon: {
                Image(systemName: "square.stack.3d.up")
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

// MARK: - Environment

struct MainTabKey: EnvironmentKey {
    static var defaultValue = Binding.constant(MainTab.home)
}

extension EnvironmentValues {
    var mainTab: Binding<MainTab> {
        get { self[MainTabKey.self] }
        set { self[MainTabKey.self] = newValue }
    }
}
