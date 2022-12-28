//
//  Store.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/09/04.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import StoreKit

class Store: NSObject {
    static let shared = Store(
        productID: EnvironmentParameter.productID,
        onPurchaseStatusUpdated: {
            UserDefaults.isSubscribeOn = $0
        })

    private let productID: String
    private let onPurchaseStatusUpdated: ((Bool) -> Void)?

    private init(productID: String,
                 onPurchaseStatusUpdated: ((Bool) -> Void)?) {
        self.productID = productID
        self.onPurchaseStatusUpdated = onPurchaseStatusUpdated
    }
}

extension Store {
    func open() {
        Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    return
                }

                if transaction.revocationDate != nil {
                    self.onPurchaseStatusUpdated?(false)
                } else if let expirationDate = transaction.expirationDate, expirationDate < Date() {
                    return
                } else if transaction.isUpgraded {
                    return
                } else {
                    self.onPurchaseStatusUpdated?(true)
                }
            }
        }
    }

    func product() async throws -> Product? {
        let products = try await Product.products(for: [productID])
        return products.first { $0.id == productID }
    }

    func purchase(product: Product) async throws {
        _ = try await product.purchase()
    }

    func restore() async throws {
        try await AppStore.sync()
    }
}
