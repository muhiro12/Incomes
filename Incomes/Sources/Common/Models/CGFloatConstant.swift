//
//  CGFloatConstant.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/23.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

extension CGFloat {
    private static let unit = Self(8)

    static let spaceS = unit * 1
    static let spaceM = unit * 2
    static let spaceL = unit * 4

    static let iconS = unit * 1
    static let iconM = unit * 5
    static let iconL = unit * 8

    static let componentXS = unit * 8
    static let componentS = unit * 10
    static let componentM = unit * 15
    static let componentL = unit * 30
    static let componentXL = unit * 40

    // MARK: - Ratio

    static let medium = Self(Double.medium)
    static let high = Self(Double.high)
}
