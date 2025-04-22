//
//  AppStorageKey.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

enum StringAppStorageKey: String {
    case currencyCode = "R8k2Z3tL"
}

enum BoolAppStorageKey: String {
    case isSubscribeOn = "a018f613"
    case isICloudOn = "X7b9C4tZ"
    case isDebugOn = "a1B2c3D4"
}

enum CodableAppStorageKey: String {
    case notificationSettings = "A3b9Z1xQ"
}

extension AppStorage {
    init(_ key: StringAppStorageKey) where Value == String {
        self.init(wrappedValue: .empty, key.rawValue)
    }

    init(_ key: BoolAppStorageKey) where Value == Bool {
        self.init(wrappedValue: false, key.rawValue)
    }

    init(_ key: CodableAppStorageKey) where Value: AppStorageCodable {
        self.init(wrappedValue: .init(), key.rawValue)
    }
}
