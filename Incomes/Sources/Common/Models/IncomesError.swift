//
//  IncomesError.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/31.
//

import Foundation

protocol IncomesError: LocalizedError {
    var resource: LocalizedStringResource { get }
}

extension IncomesError {
    var errorDescription: String? {
        .init(localized: resource)
    }
}
