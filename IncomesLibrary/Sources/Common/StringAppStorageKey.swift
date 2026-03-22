//
//  AppStorageKey.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//

import Foundation
import SwiftUI

public enum StringAppStorageKey: String {
    case currencyCode = "R8k2Z3tL"
    case lastLaunchedAppVersion = "j4N7v2Qk"
}

public extension AppStorage {
    /// Documented for SwiftLint compliance.
    init(
        _ key: StringAppStorageKey,
        store: UserDefaults = .standard
    ) where Value == String {
        self.init(
            wrappedValue: .empty,
            key.rawValue,
            store: store
        )
    }

    /// Documented for SwiftLint compliance.
    init(
        _ key: StringAppStorageKey,
        default defaultValue: String,
        store: UserDefaults = .standard
    ) where Value == String {
        self.init(
            wrappedValue: defaultValue,
            key.rawValue,
            store: store
        )
    }

    /// Documented for SwiftLint compliance.
    init(
        _ key: BoolAppStorageKey,
        store: UserDefaults = .standard
    ) where Value == Bool {
        self.init(
            wrappedValue: false,
            key.rawValue,
            store: store
        )
    }

    /// Documented for SwiftLint compliance.
    init(
        _ key: NotificationSettingsAppStorageKey,
        store: UserDefaults = .standard
    ) where Value == NotificationSettings {
        self.init(
            wrappedValue: .init(),
            key.rawValue,
            store: store
        )
    }

    /// Documented for SwiftLint compliance.
    init(
        _ key: NotificationSettingsAppStorageKey,
        default defaultValue: Value,
        store: UserDefaults = .standard
    ) where Value: RawRepresentable, Value.RawValue == String {
        self.init(
            wrappedValue: defaultValue,
            key.rawValue,
            store: store
        )
    }
}
