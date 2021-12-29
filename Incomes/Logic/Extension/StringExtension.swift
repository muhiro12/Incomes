//
//  StringExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension String {
    var isNotEmpty: Bool {
        !isEmpty
    }

    var isEmptyOrDecimal: Bool {
        if isEmpty {
            return true
        }
        return NSDecimalNumber(string: self) != NSDecimalNumber.notANumber
    }

    var decimalValue: NSDecimalNumber {
        let value = NSDecimalNumber(string: self)
        if value == NSDecimalNumber.notANumber {
            return .zero
        }
        return value
    }
}
