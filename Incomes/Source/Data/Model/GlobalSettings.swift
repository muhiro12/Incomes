//
//  GlobalSettings.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/24.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

enum GlobalSettings: String {
    case modernStyleKey = "89b736bb"
    case lockAppKey = "d8a87635"
    case iCloudKey = "93bdfd83"
    case subscribeKey = "a018f613"

    @UserDefault(key: .modernStyleKey, defaultValue: true)
    static var modernStyle: Bool

    @UserDefault(key: .lockAppKey, defaultValue: false)
    static var lockApp: Bool

    @UserDefault(key: .iCloudKey, defaultValue: false)
    static var iCloud: Bool

    @UserDefault(key: .subscribeKey, defaultValue: false)
    static var subscribe: Bool
}

class ModernStyle: ObservableObject {
    var isOn = GlobalSettings.modernStyle {
        didSet {
            GlobalSettings.modernStyle = isOn
        }
    }
}

class LockApp: ObservableObject {
    var isOn = GlobalSettings.lockApp {
        didSet {
            GlobalSettings.lockApp = isOn
        }
    }
}

class ICloud: ObservableObject {
    var isOn = GlobalSettings.iCloud {
        didSet {
            GlobalSettings.iCloud = isOn
        }
    }
}

class Subscribe: ObservableObject {
    var isOn = GlobalSettings.subscribe {
        didSet {
            GlobalSettings.subscribe = isOn
        }
    }
}
