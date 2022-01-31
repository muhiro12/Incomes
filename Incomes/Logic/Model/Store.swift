//
//  Store.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/09/04.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import Purchases

class Store: NSObject {
    static let shared = Store(
        apiKey: EnvironmentParameter.revenueCatAPIKey,
        entitlementID: "pro",
        productID: EnvironmentParameter.productID,
        onPurchaseStatusUpdated: {
            UserDefaults.isSubscribeOn = $0
        })

    private let apiKey: String
    private let entitlementID: String
    private let productID: String
    private let onPurchaseStatusUpdated: ((Bool) -> Void)?

    private init(apiKey: String,
                 entitlementID: String,
                 productID: String,
                 onPurchaseStatusUpdated: ((Bool) -> Void)?) {
        self.apiKey = apiKey
        self.entitlementID = entitlementID
        self.productID = productID
        self.onPurchaseStatusUpdated = onPurchaseStatusUpdated
    }
}

extension Store {
    func open() {
        #if DEBUG
        Purchases.logLevel = .warn
        #endif
        Purchases.configure(withAPIKey: apiKey)
        Purchases.shared.delegate = self
    }

    func product() async throws -> SKProduct? {
        try await withCheckedThrowingContinuation { continuation in
            Purchases.shared.offerings { offerings, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let products = offerings?.current?.availablePackages.map {
                    $0.product
                }
                let product = products?.first(where: {
                    $0.productIdentifier == self.productID
                })
                continuation.resume(returning: product)
            }
        }
    }

    func purchase(product: SKProduct) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Purchases.shared.purchaseProduct(product) { _, _, error, userCancelled in
                if !userCancelled, let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: ())
            }
        }
    }

    func restore() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Purchases.shared.restoreTransactions { purchaserInfo, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if purchaserInfo?.entitlements.all.filter({ $0.value.isActive }).isEmpty == true {
                    continuation.resume(throwing: StoreError.noPurchases)
                    return
                }
                continuation.resume(returning: ())
            }
        }
    }
}

extension Store: PurchasesDelegate {
    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
        let isActive = purchaserInfo.entitlements.all[entitlementID]?.isActive ?? false
        onPurchaseStatusUpdated?(isActive)
    }
}
