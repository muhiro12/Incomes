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
    static let defaultValue = Binding.constant(MainTab.home)
}

extension EnvironmentValues {
    var mainTab: Binding<MainTab> {
        get { self[MainTabKey.self] }
        set { self[MainTabKey.self] = newValue }
    }
}
