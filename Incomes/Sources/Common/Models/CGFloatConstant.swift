//
//  CGFloatConstant.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/23.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import SwiftUI

extension CGFloat {
    enum Size {
        case xs
        case s
        case m
        case l
        case xl
    }

    private static let unit = Self(8)

    static func space(_ size: Size) -> Self {
        switch size {
        case .xs:
            unit * 0.5
        case .s:
            unit * 1
        case .m:
            unit * 2
        case .l:
            unit * 4
        case .xl:
            unit * 5
        }
    }

    static func icon(_ size: Size) -> Self {
        switch size {
        case .xs:
            unit * 0.5
        case .s:
            unit * 1
        case .m:
            unit * 5
        case .l:
            unit * 6
        case .xl:
            unit * 8
        }
    }

    static func component(_ size: Size) -> Self {
        switch size {
        case .xs:
            unit * 8
        case .s:
            unit * 10
        case .m:
            unit * 15
        case .l:
            unit * 30
        case .xl:
            unit * 40
        }
    }

    static let minimumScaleFactor = 0.5
}
