//
//  SidebarItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/25.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation

enum SidebarItem: String, Identifiable {
    case home
    case category

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .home:
            return .localized(.homeTitle)

        case .category:
            return .localized(.categoryTitle)
        }
    }

    var image: String {
        switch self {
        case .home:
            return .imageHome

        case .category:
            return .imageCategory
        }
    }
}
