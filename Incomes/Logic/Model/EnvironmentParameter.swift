//
//  EnvironmentParameter.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/09/04.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

// periphery:ignore
enum EnvironmentParameter {
    static let isDebug = {
        #if DEBUG
        true
        #else
        false
        #endif
    }()

    static let groupID = {
        isDebug
            ? Secret.groupIDDev.rawValue
            : Secret.groupID.rawValue
    }()

    static let productID = {
        Secret.productID.rawValue
    }()

    static let admobNativeID = {
        isDebug
            ? Secret.admobNativeIDDev.rawValue
            : Secret.admobNativeID.rawValue
    }()
}
