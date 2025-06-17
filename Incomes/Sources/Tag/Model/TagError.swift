//
//  TagError.swift
//  Incomes
//
//  Created by Codex on 2025/06/17.
//

import Foundation

enum TagError: IncomesError {
    case tagNotFound

    var resource: LocalizedStringResource {
        switch self {
        case .tagNotFound:
            return .init(stringLiteral: "Tag not found")
        }
    }
}

