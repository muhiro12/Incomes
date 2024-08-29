//
//  IncomesPath.swift
//
//
//  Created by Hiromu Nakano on 2024/06/18.
//

import SwiftUI

enum IncomesPath: Hashable {
    case home
    case category
    case debug
    case itemList(Tag)
    case item(Item)
    case tagList
    case tag(Tag)
    case license
}

extension IncomesPath {
    @ViewBuilder
    var view: some View {
        switch self {
        case .home:
            HomeView()
        case .category:
            CategoryView()
        case .debug:
            DebugView()
        case .itemList(let tag):
            ItemListView(tag: tag) { yearTag in
                if tag.type == .yearMonth,
                   let date = tag.items?.first?.date {
                    return Item.descriptor(dateIsSameMonthAs: date)
                }
                if tag.type == .content {
                    return Item.descriptor(content: tag.name,
                                           year: yearTag.name)
                }
                return Item.descriptor(predicate: .false)
            }
        case .item(let item):
            ItemFormView(mode: .edit, item: item)
        case .tagList:
            TagListView()
        case .tag(let tag):
            TagView()
                .environment(tag)
        case .license:
            LicenseView()
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
