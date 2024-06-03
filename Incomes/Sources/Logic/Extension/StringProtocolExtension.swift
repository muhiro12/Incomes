//
//  StringProtocolExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation

extension StringProtocol where Self == String {
    static func key(_ key: UserDefaults.Key) -> String {
        key.rawValue
    }
}
