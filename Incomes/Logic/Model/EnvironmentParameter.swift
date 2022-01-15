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

    static var revenueCatAPIKey: String = {
        #if DEBUG
        return Secret.revenueCatAPIKeyDev.rawValue
        #else
        return Secret.revenueCatAPIKey.rawValue
        #endif
    }()

    static var admobBannerID: String = {
        #if DEBUG
        return Secret.admobBannerIDDev.rawValue
        #else
        // TODO: Use production id
        return Secret.admobBannerIDDev.rawValue
        #endif
    }()

    static var admobNativeID: String = {
        #if DEBUG
        return Secret.admobNativeIDDev.rawValue
        #else
        // TODO: Use production id
        return Secret.admobNativeIDDev.rawValue
        #endif
    }()
}
