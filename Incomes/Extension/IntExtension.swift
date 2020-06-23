//
//  IntExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Int {
    var asCurrency: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: self))
    }

    var asMinusCurrency: String? {
        return (-self).asCurrency
    }
}
