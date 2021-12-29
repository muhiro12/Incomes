//
//  UUIDExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation

extension UUID {
    var nsValue: NSUUID {
        NSUUID(uuidString: uuidString)!
    }
}
