//
//  EnvironmentParameter.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/09/04.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

enum EnvironmentParameter {
    static let isDebug = {
        #if DEBUG
        true
        #else
        false
        #endif
    }()

    static let productID = {
        #if DEBUG
        Secret.productIDDev.rawValue
        #else
        Secret.productID.rawValue
        #endif
    }()

    static let admobNativeID: String = {
        #if DEBUG
        Secret.admobNativeIDDev.rawValue
        #else
        Secret.admobNativeID.rawValue
        #endif
    }()
}
