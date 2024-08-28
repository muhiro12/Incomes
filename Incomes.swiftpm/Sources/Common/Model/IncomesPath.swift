//
//  IncomesPath.swift
//
//
//  Created by Hiromu Nakano on 2024/06/18.
//

import SwiftUI

enum IncomesPath: Hashable {
    case debug
    case itemList(Tag)
    case item(Item)
    case tagList
    case tag(Tag)
    case license
}

extension View {
    func incomesNavigationDestination() -> some View {
        navigationDestination(for: IncomesPath.self) {
            switch $0 {
            case .debug:
                DebugView()
            case .itemList(let tag):
                ItemListView(tag: tag) { _ in Item.descriptor() }
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
}

extension NavigationLink where Destination == Never {
    init(path: IncomesPath, @ViewBuilder label: () -> Label) {
        self.init(value: path, label: label)
    }
}
