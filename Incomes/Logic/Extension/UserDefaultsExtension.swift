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
                standard.object(forKey: key.rawValue) as? T ?? defaultValue
            }
            set {
                standard.set(newValue, forKey: key.rawValue)
            }
        }
    }

    enum Key: String {
        case isSubscribeOn = "a018f613"
        case isMaskAppOn = "aa9f2c8b"
        case isLockAppOn = "d8a87635"
    }

    @UserDefaults.Wrapper(key: .isSubscribeOn, defaultValue: false)
    static var isSubscribeOn: Bool {
        didSet {
            guard !isSubscribeOn else {
                return
            }
            isMaskAppOn = true
            isLockAppOn = false
        }
    }

    @UserDefaults.Wrapper(key: .isMaskAppOn, defaultValue: true)
    static var isMaskAppOn: Bool

    @UserDefaults.Wrapper(key: .isLockAppOn, defaultValue: false)
    static var isLockAppOn: Bool
}
