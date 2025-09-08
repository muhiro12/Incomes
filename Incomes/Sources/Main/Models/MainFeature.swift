//
//  MainFeature.swift
//  Incomes
//
//  Defines the top-level features selectable from the Sidebar.
//

import SwiftUI

enum MainFeature {
    case home
    case content
    case category
    case search
}

extension MainFeature {
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

extension MainFeature: CaseIterable {}

extension MainFeature: Identifiable {
    var id: String {
        .init(describing: self)
    }
}
