//
//  DebugError.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/15.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation

enum DebugError: IncomesError {
    case `default`

    var message: String {
        switch self {
        case .default:
            let message = String.localized(.errorUnknown)
            assertionFailure(message)
            return message
        }
    }
}
