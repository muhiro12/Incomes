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

    static var spaceS: Self { unit * 1 }
    static var spaceM: Self { unit * 2 }
    static var spaceL: Self { unit * 3 }

    static var componentS: Self { unit * 8 }
    static var componentM: Self { unit * 10 }
    static var componentL: Self { unit * 12 }

    static var icon: Self { unit * 3 }
}
