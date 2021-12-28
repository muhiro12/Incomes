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

extension StringProtocol where Self == String {
    static func localized(_ localizedString: LocalizedString) -> String {
        NSLocalizedString(String(describing: localizedString), comment: .empty)
    }
}
