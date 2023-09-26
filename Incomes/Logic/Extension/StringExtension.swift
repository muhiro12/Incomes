//
//  StringExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension String {
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

    func dateValue(_ template: DateFormatter.Template, locale: Locale = .current) -> Date? {
        DateFormatter.formatter(template, locale: locale).date(from: self)
    }

    func dateValueWithoutLocale(_ template: DateFormatter.Template) -> Date? {
        DateFormatter.formatterWithoutLocale(template).date(from: self)
    }
}
