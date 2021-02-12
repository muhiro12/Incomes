//
//  Store.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/09/04.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftyStoreKit

struct Store {
    private var purchased = Purchased()
    private let productId: String
    private let validator: AppleReceiptValidator

    init(productId: String, validator: AppleReceiptValidator) {
        self.productId = productId
        self.validator = validator
    }

    func purchase() {
        SwiftyStoreKit.purchaseProduct(productId) { result in
            switch result {
            case .success:
                verifyPurchase()
            case .error(let error):
                print(error)
                purchased.isOn = false
            }
        }
    }

    func verifyPurchase() {
        SwiftyStoreKit.verifyReceipt(using: validator) { result in
            switch result {
            case .success(let receipt):
                self.verifySubscription(receipt: receipt)
            case .error(let error):
                print(error)
                purchased.isOn = false
            }
        }
    }

    func verifySubscription(receipt: ReceiptInfo) {
        let result = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable,
                                                       productId: productId,
                                                       inReceipt: receipt)
        switch result {
        case .purchased:
            purchased.isOn = true
        case .notPurchased, .expired:
            purchased.isOn = false
        }
    }

    static func check() {
        SwiftyStoreKit.completeTransactions { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    Purchased().isOn = false
                @unknown default:
                    fatalError()
                }
            }
        }
    }
}
