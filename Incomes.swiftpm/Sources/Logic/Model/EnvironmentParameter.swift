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
        "TODO"// Secret.groupID.rawValue
    }()

    static let productID = {
        "TODO"// Secret.productID.rawValue
    }()

    static let admobNativeID = {
        "TODO"
        //        isDebug
        //            ? Secret.admobNativeIDDev.rawValue
        //            : Secret.admobNativeID.rawValue
    }()
}
