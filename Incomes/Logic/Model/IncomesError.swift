//
//  IncomesError.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/31.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation

protocol IncomesError: LocalizedError {
    var message: String { get }
}

extension IncomesError {
    var errorDescription: String? {
        message
    }
}
