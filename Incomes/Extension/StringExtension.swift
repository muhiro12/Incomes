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
        return !isEmpty
    }

    var isEmptyOrNaturalNumber: Bool {
        if isEmpty {
            return true
        }
        guard let int = Int(self) else {
            return false
        }
        return int > 0
    }

    var isEmptyOrDecimal: Bool {
        if isEmpty {
            return true
        }
        return Decimal(string: self) != nil
    }

    var decimalValue: Decimal {
        return Decimal(string: self) ?? .zero
    }
}
