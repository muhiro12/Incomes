//
//  OptionalExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Optional {
    var unwrappedString: String {
        (self as? String).unwrapped
    }
}

extension Optional where Wrapped == String {
    var unwrapped: Wrapped {
        self ?? ""
    }
}

extension Optional where Wrapped == [Any] {
    var unwrapped: Wrapped {
        self ?? []
    }
}
extension Optional where Wrapped == Date {
    var unwrapped: Wrapped {
        self ?? Date()
    }
}

extension Optional where Wrapped == Decimal {
    var unwrapped: Wrapped {
        self ?? .zero
    }
}

extension Optional where Wrapped == NSDecimalNumber {
    var unwrapped: Wrapped {
        self ?? .zero
    }
}
