//
//  IncomesPath.swift
//
//
//  Created by Hiromu Nakano on 2024/06/18.
//

import SwiftUI

enum IncomesPath: Hashable {
    case debug
    case duplicatedTag(Tag)
    case duplicatedTags
    case license
}

extension View {
    func incomesNavigationDestination() -> some View {
        navigationDestination(for: IncomesPath.self) {
            switch $0 {
            case .debug:
                DebugView()
            case .duplicatedTag(let tag):
                DuplicatedTagView(tag)
            case .duplicatedTags:
                DuplicatedTagsView()
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
