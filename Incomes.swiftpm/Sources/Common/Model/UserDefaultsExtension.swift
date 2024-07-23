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

    public enum Key: String {
        case isSubscribeOn = "a018f613"
        case isICloudOn = "X7b9C4tZ"
        case isMaskAppOn = "aa9f2c8b"
    }

    @UserDefaults.Wrapper(key: .isSubscribeOn, defaultValue: false)
    static var isSubscribeOn: Bool {
        didSet {
            guard !isSubscribeOn else {
                return
            }

            [Key]([
                .isICloudOn,
                .isMaskAppOn
            ])
            .map { $0.rawValue }
            .forEach(standard.removeObject)
        }
    }

    @UserDefaults.Wrapper(key: .isICloudOn, defaultValue: false)
    static var isICloudOn: Bool

    @UserDefaults.Wrapper(key: .isMaskAppOn, defaultValue: true)
    static var isMaskAppOn: Bool
}
