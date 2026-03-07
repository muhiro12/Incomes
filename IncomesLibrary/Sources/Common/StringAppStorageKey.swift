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
    /// Creates a string `AppStorage` binding for the given string storage key.
    init(_ key: StringAppStorageKey) where Value == String {
        self.init(
            key.preferenceKey,
            default: .empty
        )
    }

    /// Creates a boolean `AppStorage` binding for the given boolean storage key.
    init(_ key: BoolAppStorageKey) where Value == Bool {
        self.init(key.preferenceKey)
    }

    /// Creates a notification-settings `AppStorage` binding for the given storage key.
    init(_ key: NotificationSettingsAppStorageKey) where Value == NotificationSettings {
        self.init(
            key.preferenceKey,
            default: .init()
        )
    }
}
