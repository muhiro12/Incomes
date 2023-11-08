//
//  DebugError.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/15.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation

// periphery:ignore
enum DebugError: IncomesError {
    case `default`

    var resource: LocalizedStringResource {
        switch self {
        case .default:
            let message = "Sorry, something went wrong. We're working to fix it."
            assertionFailure(message)
            return .init(stringLiteral: message)
        }
    }
}
