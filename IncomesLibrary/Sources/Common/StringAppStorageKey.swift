//
//  AppStorageKey.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//

import MHPreferences
import SwiftUI

public enum StringAppStorageKey: String, MHStringPreferenceKeyRepresentable {
    case currencyCode = "R8k2Z3tL"
    case lastLaunchedAppVersion = "j4N7v2Qk"

    public var preferenceKey: MHStringPreferenceKey {
        .init(storageKey: rawValue)
    }
}

public extension AppStorage {
    /// Creates a boolean app-storage binding for the given storage key.
    init(
        _ key: BoolAppStorageKey,
        store: UserDefaults = .standard
    ) where Value == Bool {
        self.init(
            key.preferenceKey,
            store: store
        )
    }

    /// Creates a string app-storage binding for the given storage key.
    init(
        _ key: StringAppStorageKey,
        store: UserDefaults = .standard
    ) where Value == String {
        self.init(
            key.preferenceKey,
            default: "",
            store: store
        )
    }

    /// Creates a notification-settings `AppStorage` binding for the given storage key.
    init(
        _ key: NotificationSettingsAppStorageKey,
        store: UserDefaults = .standard
    ) where Value == NotificationSettings {
        self.init(
            key.preferenceKey,
            default: .init(),
            store: store
        )
    }
}
