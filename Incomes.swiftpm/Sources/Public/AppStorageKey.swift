//
//  AppStorageKey.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import SwiftUI

public enum AppStorageKey: String {
    case isSubscribeOn = "a018f613"
    case isICloudOn = "X7b9C4tZ"
    case isDebugOn = "a1B2c3D4"
}

public extension AppStorage<Bool> {
    init(_ key: AppStorageKey) {
        self.init(wrappedValue: false, key.rawValue)
    }
}
