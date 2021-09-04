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
    case iCloudKey = "93bdfd83"
    case purchasedKey = "a018f613"

    @UserDefault(key: .modernStyleKey, defaultValue: true)
    static var modernStyle: Bool

    @UserDefault(key: .iCloudKey, defaultValue: false)
    static var iCloud: Bool

    @UserDefault(key: .purchasedKey, defaultValue: false)
    static var purchased: Bool
}

class ModernStyle: ObservableObject {
    var isOn = GlobalSettings.modernStyle {
        didSet {
            GlobalSettings.modernStyle = isOn
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

class Purchased: ObservableObject {
    var isOn = GlobalSettings.purchased {
        didSet {
            GlobalSettings.purchased = isOn
        }
    }
}
