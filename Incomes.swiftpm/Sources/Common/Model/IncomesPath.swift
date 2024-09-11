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
    case year(Tag)
    // MARK: Item
    case itemFormNavigation(mode: ItemFormView.Mode, item: Item)
    case itemForm(mode: ItemFormView.Mode, item: Item)
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
        case .year(let tag):
            YearView()
                .environment(tag)
        case .itemFormNavigation(let mode, let item):
            ItemFormNavigationView(mode: mode, item: item)
        case .itemForm(let mode, let item):
            ItemFormView(mode: mode, item: item)
        case .itemList(let tag):
            ItemListView(tag: tag) { yearTag in
                switch tag.type {
                case .year:
                    if let date = tag.items?.first?.date {
                        return Item.descriptor(.dateIsSameYearAs(date))
                    }
                case .yearMonth:
                    if let date = tag.items?.first?.date {
                        return Item.descriptor(.dateIsSameMonthAs(date))
                    }
                case .content:
                    return Item.descriptor(.contentAndYear(content: tag.name, year: yearTag.name))
                case .category:
                    break
                case .none:
                    break
                }
                return Item.descriptor(.none)
            }
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
