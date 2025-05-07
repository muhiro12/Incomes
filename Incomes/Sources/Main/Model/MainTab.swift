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
    case search
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
            case .search:
                SearchNavigationView()
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
                Image(systemName: "doc.text")
            }
        case .category:
            Label {
                Text("Category")
            } icon: {
                Image(systemName: "tag")
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
        case .search:
            Label {
                Text("Search")
            } icon: {
                Image(systemName: "magnifyingglass")
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
