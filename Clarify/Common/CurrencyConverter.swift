//
//  CurrencyConverter.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/11.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

struct CurrencyConverter {
    func convert(_ int: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: int)) ?? ""
    }
}
