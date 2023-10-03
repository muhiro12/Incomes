//
//  CGFloatConstant.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/23.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

// periphery:ignore
// swiftlint:disable no_magic_numbers
extension CGFloat {
    private static let unit = Self(8)

    static let spaceS = unit * 1
    static let spaceM = unit * 2
    static let spaceL = unit * 3

    static let componentS = unit * 8
    static let componentM = unit * 16
    static let componentL = unit * 24

    static let iconS = unit * 1
    static let iconM = unit * 3
    static let iconL = unit * 5

    static let portraitModeMaxWidth = unit * 60

    static let advertisementMaxWidth = unit * 45

    // MARK: - Ratio

    static let low = Self(Double.low)
    static let medium = Self(Double.medium)
    static let high = Self(Double.high)
}
// swiftlint:enable no_magic_numbers
