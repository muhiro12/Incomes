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
    static let spaceL = unit * 3

    static let componentS = unit * 8
    static let componentM = unit * 12
    static let componentL = unit * 16
    static let componentXL = unit * 32

    static let iconS = unit * 1

    // MARK: - Ratio

    static let medium = Self(Double.medium)
    static let high = Self(Double.high)
}
