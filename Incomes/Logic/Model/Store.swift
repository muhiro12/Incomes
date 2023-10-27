//
//  Store.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/09/04.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import StoreKit

@Observable
final class Store {
    let groupID = EnvironmentParameter.groupID
    let productIDs = [EnvironmentParameter.productID]

    private(set) var product: Product?

    private var subscriptions: [Product] {
        didSet {
            product = subscriptions.first { productIDs.contains($0.id) }
        }
    }
    private var purchasedSubscriptions: [Product] = [] {
        didSet {
            UserDefaults.isSubscribeOn = purchasedSubscriptions.contains { productIDs.contains($0.id) }
        }
    }

    private var updateListenerTask: Task<Void, Error>?

    init() {
        subscriptions = []

        updateListenerTask = listenForTransactions()

        Task {
            await requestProducts()
            await updateCustomerProductStatus()
        }
    }

    func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    await self.updateCustomerProductStatus()

                    await transaction.finish()
                } catch {
                    assertionFailure("Transaction failed verification: \(error.localizedDescription)")
                }
            }
        }
    }

    @MainActor
    func requestProducts() async {
        do {
            subscriptions = try await Product.products(for: productIDs)
        } catch {
            assertionFailure("Failed product request from the App Store server: \(error)")
        }
    }

    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedSubscriptions: [Product] = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        purchasedSubscriptions.append(subscription)
                    }

                default:
                    break
                }
            } catch {
                assertionFailure("Transaction failed verification: \(error.localizedDescription)")
            }
        }

        self.purchasedSubscriptions = purchasedSubscriptions
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw DebugError.default

        case .verified(let safe):
            return safe
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }
}
