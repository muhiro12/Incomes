//
//  Store.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/09/04.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

struct Store {
    private var purchased = Purchased()
    private let productId: String
    
    init(productId: String) {
        self.productId = productId
    }

    func purchase() {
        // TODO: Subscribe
    }

    static func check() {
        // TODO: Validate receipt
    }
}
