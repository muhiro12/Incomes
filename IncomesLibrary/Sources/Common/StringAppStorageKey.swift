//
//  AppStorageKey.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//

import MHPreferences
import SwiftUI

public enum StringAppStorageKey: String {
    case currencyCode = "R8k2Z3tL"
    case lastLaunchedAppVersion = "j4N7v2Qk"

    public var preferenceKey: MHStringPreferenceKey {
        .init(storageKey: rawValue)
    }
}

public extension AppStorage {
    /// Documented for SwiftLint compliance.
    init(_ key: StringAppStorageKey) where Value == String {
        self.init(
            key.preferenceKey,
            default: .empty
        )
    }

    /// Documented for SwiftLint compliance.
    init(_ key: BoolAppStorageKey) where Value == Bool {
        self.init(key.preferenceKey)
    }

    /// Documented for SwiftLint compliance.
    init(_ key: NotificationSettingsAppStorageKey) where Value == NotificationSettings {
        self.init(
            key.preferenceKey,
            default: .init()
        )
    }
}
