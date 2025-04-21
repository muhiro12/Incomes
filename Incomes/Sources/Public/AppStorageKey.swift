//
//  BoolAppStorageKey.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

public enum StringAppStorageKey: String {
    case currencyCode = "R8k2Z3tL"
}

public enum BoolAppStorageKey: String {
    case isSubscribeOn = "a018f613"
    case isICloudOn = "X7b9C4tZ"
    case isDebugOn = "a1B2c3D4"
}

public extension AppStorage {
    init(_ key: StringAppStorageKey) where Value == String {
        self.init(wrappedValue: .empty, key.rawValue)
    }

    init(_ key: BoolAppStorageKey) where Value == Bool {
        self.init(wrappedValue: false, key.rawValue)
    }
}
