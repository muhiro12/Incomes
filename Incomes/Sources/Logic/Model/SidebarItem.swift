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

    var title: LocalizedStringResource {
        switch self {
        case .home:
            return "Home"

        case .category:
            return "Category"
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
