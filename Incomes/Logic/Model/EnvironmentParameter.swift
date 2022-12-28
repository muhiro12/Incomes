//
//  EnvironmentParameter.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/09/04.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

struct EnvironmentParameter {
    private init() {}

    static var productID: String = {
        #if DEBUG
        return Secret.productIDDev.rawValue
        #else
        return Secret.productID.rawValue
        #endif
    }()

    static var admobNativeID: String = {
        #if DEBUG
        return Secret.admobNativeIDDev.rawValue
        #else
        return Secret.admobNativeID.rawValue
        #endif
    }()
}
