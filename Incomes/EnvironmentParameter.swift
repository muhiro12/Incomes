//
//  EnvironmentParameter.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/09/04.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftyStoreKit

struct EnvironmentParameter {
    static var productId: String {
        #if DEBUG
        return Secret.productIDDev.rawValue
        #else
        return Secret.productID.rawValue
        #endif
    }

    static var appleValidator: AppleReceiptValidator {
        #if DEBUG
        return .init(service: .sandbox, sharedSecret: Secret.sharedSecret.rawValue)
        #else
        return .init(service: .production, sharedSecret: Secret.sharedSecret.rawValue)
        #endif
    }
}
