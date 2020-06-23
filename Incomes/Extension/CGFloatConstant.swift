//
//  CGFloatConstant.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/23.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import UIKit

extension CGFloat {
    private static var unit: Self { 8 }

    static var iconS: Self { unit * 3 }
    static var iconM: Self { unit * 6 }
    static var iconL: Self { unit * 9 }

    static var componentS: Self { unit * 8 }
    static var componentM: Self { unit * 10 }
    static var componentL: Self { unit * 12 }
}
