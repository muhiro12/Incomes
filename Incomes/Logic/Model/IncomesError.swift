//
//  IncomesError.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/31.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation

// TODO: Resolve SwiftLint
// swiftlint:disable file_types_order
protocol IncomesError: Error {
    var message: String { get }
}

enum StoreError: IncomesError {
    case noPurchases

    var message: String {
        switch self {
        case .noPurchases:
            return .localized(.noPurchases)
        }
    }
}
// swiftlint:enable file_types_order
