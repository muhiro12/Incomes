//
//  Scene.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

enum Scene {
    case home
    case group
}

extension Scene {
    var isHome: Bool {
        return self == .home
    }

    mutating func toNext() {
        switch self {
        case .home:
            self = .group
        case .group:
            self = .home
        }
    }
}
