//
//  StringConstant.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/22.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension String {
    // MARK: - Common
    static var empty: Self { "" }
    static var zero: Self { "0" }

    // MARK: - Image SystemName
    static var homeIcon: Self { "calendar" }
    static var groupIcon: Self { "square.stack.3d.up" }
    static var settingsIcon: Self { "gear" }
    static var createIcon: Self { "square.and.pencil" }
    static var arrowUpIcon: Self { "arrow.up" }

    // MARK: - Identifier
    static var item: Self { "Item" }
}
