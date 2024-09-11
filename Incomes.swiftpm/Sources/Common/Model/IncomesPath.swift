//
//  IncomesPath.swift
//
//
//  Created by Hiromu Nakano on 2024/06/18.
//

import SwiftUI

enum IncomesPath: Hashable {
    // MARK: Category
    case category
    // MARK: Debug
    case debug
    // MARK: Home
    case home
    case year(Date)
    // MARK: Item
    case itemFormNavigation(mode: ItemFormView.Mode)
    case itemForm(mode: ItemFormView.Mode)
    case itemList(Tag)
    // MARK: Main
    case mainNavigationContent
    case mainNavigationDetail
    case mainNavigationSidebar
    case mainNavigation
    case main
    // MARK: Package
    case license
    // MARK: Public
    case content
    // MARK: Settings
    case settingsNavigation
    case settings
    // MARK: Tag
    case duplicateTagList
    case duplicateTagNavigation
    case duplicateTag(Tag)
    case tagList
    case tag(Tag)
}

extension IncomesPath {
    @MainActor
    @ViewBuilder
    var view: some View {
        switch self {
        case .category:
            CategoryView()
        case .debug:
            DebugView()
        case .home:
            HomeView()
        case .year(let date):
            YearView(date: date)
        case .itemFormNavigation(let mode):
            ItemFormNavigationView(mode: mode)
        case .itemForm(let mode):
            ItemFormView(mode: mode)
        case .itemList(let tag):
            ItemListView()
                .environment(tag)
        case .mainNavigationContent:
            MainNavigationContentView(nil)
        case .mainNavigationDetail:
            MainNavigationDetailView(nil)
        case .mainNavigationSidebar:
            MainNavigationSidebarView()
        case .mainNavigation:
            MainNavigationView()
        case .main:
            MainView()
        case .license:
            LicenseView()
        case .content:
            ContentView()
        case .settingsNavigation:
            SettingsNavigationView()
        case .settings:
            SettingsView()
        case .duplicateTagList:
            DuplicateTagListView(selection: .constant(nil))
        case .duplicateTagNavigation:
            DuplicateTagNavigationView()
        case .duplicateTag(let tag):
            DuplicateTagView(tag)
        case .tagList:
            TagListView()
        case .tag(let tag):
            TagView()
                .environment(tag)
        }
    }
}

extension View {
    func incomesNavigationDestination() -> some View {
        navigationDestination(for: IncomesPath.self) {
            $0.view
        }
    }
}

extension NavigationLink where Destination == Never {
    init(path: IncomesPath, @ViewBuilder label: () -> Label) {
        self.init(value: path, label: label)
    }
}

enum PathSelectionEnvironmentKey: EnvironmentKey {
    static var defaultValue: Binding<IncomesPath?> = .constant(nil)
}

extension EnvironmentValues {
    var pathSelection: Binding<IncomesPath?> {
        get { self[PathSelectionEnvironmentKey.self] }
        set { self[PathSelectionEnvironmentKey.self] = newValue }
    }
}
