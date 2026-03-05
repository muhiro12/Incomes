//
//  AppStorageKey.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//

import SwiftUI

public enum StringAppStorageKey: String {
    case currencyCode = "R8k2Z3tL"
    case lastLaunchedAppVersion = "j4N7v2Qk"
}

public extension AppStorage {
    /// Documented for SwiftLint compliance.
    init(_ key: StringAppStorageKey) where Value == String {
        self.init(wrappedValue: .empty, key.rawValue)
    }

    /// Documented for SwiftLint compliance.
    init(_ key: BoolAppStorageKey) where Value == Bool {
        self.init(wrappedValue: false, key.rawValue)
    }

    /// Documented for SwiftLint compliance.
    init(_ key: NotificationSettingsAppStorageKey) where Value == NotificationSettings {
        self.init(wrappedValue: .init(), key.rawValue)
    }
}
