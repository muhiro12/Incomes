//
//  ItemError.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/12.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation

enum ItemError: @preconcurrency IncomesError {
    case contentIsEmpty
    case entityConversionFailed
    case itemNotFound
    case invalidRepeatMonthSelections

    var resource: LocalizedStringResource {
        switch self {
        case .contentIsEmpty:
            return .init(stringLiteral: "Content is empty")
        case .entityConversionFailed:
            return .init(stringLiteral: "Failed to convert item entity")
        case .itemNotFound:
            return .init(stringLiteral: "Item not found")
        case .invalidRepeatMonthSelections:
            return .init(stringLiteral: "Repeat month selections are invalid")
        }
    }
}
