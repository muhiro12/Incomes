//
//  IncomesPath.swift
//
//
//  Created by Hiromu Nakano on 2024/06/18.
//

import SwiftUI

enum IncomesPath: Hashable {
    case year(Date)
    case itemForm(mode: ItemFormView.Mode)
    case itemList(Tag)
    case tag(Tag)
}

extension IncomesPath {
    @ViewBuilder
    var view: some View {
        switch self {
        case .year(let date):
            YearView(date: date)
        case .itemForm(let mode):
            ItemFormView(mode: mode)
        case .itemList(let tag):
            ItemListView()
                .environment(tag)
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
