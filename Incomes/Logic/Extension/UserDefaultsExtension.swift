//
//  UserDefaultsExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

extension UserDefaults {
    @propertyWrapper
    struct Wrapper<T> {
        let key: UserDefaults.Key
        let defaultValue: T

        var wrappedValue: T {
            get {
                return UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue
            }
            set {
                UserDefaults.standard.set(newValue, forKey: key.rawValue)
            }
        }
    }

    enum Key: String {
        case isModernStyleOn = "89b736bb"
        case isLockAppOn = "d8a87635"
        case isICloudOn = "93bdfd83"
        case isSubscribeOn = "a018f613"
    }

    @UserDefaults.Wrapper(key: .isModernStyleOn, defaultValue: true)
    static var isModernStyleOn: Bool

    @UserDefaults.Wrapper(key: .isLockAppOn, defaultValue: false)
    static var isLockAppOn: Bool

    @UserDefaults.Wrapper(key: .isICloudOn, defaultValue: false)
    static var isICloudOn: Bool

    @UserDefaults.Wrapper(key: .isSubscribeOn, defaultValue: false)
    static var isSubscribeOn: Bool
}
