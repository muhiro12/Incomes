//
//  IncomesPath.swift
//
//
//  Created by Hiromu Nakano on 2024/06/18.
//

import SwiftUI

enum IncomesPath: Hashable {
    case category
    case debug
    case home
    case year(Date)
    case itemForm(mode: ItemFormView.Mode)
    case itemList(Tag)
    case license
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
        case .itemForm(let mode):
            ItemFormView(mode: mode)
        case .itemList(let tag):
            ItemListView()
                .environment(tag)
        case .license:
            LicenseView()
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
