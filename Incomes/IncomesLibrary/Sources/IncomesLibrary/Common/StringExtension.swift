//
//  StringExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

public nonisolated extension String {
    var isEmptyOrDecimal: Bool {
        if isEmpty {
            return true
        }
        return Decimal(string: self) != nil
    }

    var decimalValue: Decimal {
        guard let value = Decimal(string: self) else {
            return .zero
        }
        return value
    }

    func dateValueWithoutLocale(_ template: DateFormatter.Template) -> Date? {
        DateFormatter.fixed(template).date(from: self)
    }
}
