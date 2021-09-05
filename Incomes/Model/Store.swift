//
//  Store.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/09/04.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import Purchases

struct Product {
    fileprivate init(package: Purchases.Package) {
        self.package = package
        self.value = package.product
    }

    fileprivate let package: Purchases.Package
    fileprivate let value: SKProduct
}

protocol StoreInterface {
    func configure()
    func loadProduct(completion: @escaping (Product?) -> Void)
    func purchase(product: Product, errorHandler: ((Error?) -> Void)?, cancelHandler: ((Bool) -> Void)?)
    func restore()
}

class Store: NSObject {
    static let shared = Store()

    private override init() {
        apiKey = EnvironmentParameter.revenueCatAPIKey
        entitlementId = "pro"
        productId = EnvironmentParameter.productId
        onPurchaseStatusUpdated = { isActive in
            if isActive {
                Subscribe().isOn = true
            } else {
                Subscribe().isOn = false
                ICloud().isOn = false
            }
        }
    }

    private let apiKey: String
    private let entitlementId: String
    private let productId: String
    private let onPurchaseStatusUpdated: (Bool) -> Void
}

// MARK: - Public

extension Store: StoreInterface {
    func configure() {
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: apiKey)
        Purchases.shared.delegate = self
    }

    func loadProduct(completion: @escaping (Product?) -> Void) {
        Purchases.shared.offerings { offerings, error in
            let products = offerings?.current?.availablePackages.map { Product(package: $0) }
            let product = products?.first(where: {
                $0.value.productIdentifier == self.productId
            })
            completion(product)
        }
    }

    func purchase(product: Product, errorHandler: ((Error?) -> Void)?, cancelHandler: ((Bool) -> Void)?) {
        Purchases.shared.purchasePackage(product.package) { transaction, purchaserInfo, error, userCancelled in
            errorHandler?(error)
            cancelHandler?(userCancelled)
        }
    }

    func restore() {
        Purchases.shared.restoreTransactions()
    }
}

extension Store: PurchasesDelegate {
    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
        let isActive = purchaserInfo.entitlements.all[entitlementId]?.isActive ?? false
        onPurchaseStatusUpdated(isActive)
    }
}
