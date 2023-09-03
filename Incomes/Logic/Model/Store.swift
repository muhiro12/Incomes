//
//  Store.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/09/04.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import StoreKit

final class Store: ObservableObject {
    @Published private(set) var isSubscribeOn = false

    @Published private(set) var subscriptionGroupStatus: Product.SubscriptionInfo.RenewalState?
    @Published private(set) var subscriptions: [Product]
    @Published private(set) var purchasedSubscriptions: [Product] = [] {
        didSet {
            isSubscribeOn = !purchasedSubscriptions.isEmpty
        }
    }

    var updateListenerTask: Task<Void, Error>?

    let productID = EnvironmentParameter.productID

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
                    print("Transaction failed verification")
                }
            }
        }
    }

    @MainActor
    func requestProducts() async {
        do {
            subscriptions = try await Product.products(for: [productID])
        } catch {
            print("Failed product request from the App Store server: \(error)")
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
                print()
            }
        }

        self.purchasedSubscriptions = purchasedSubscriptions

        subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            // TODO: Throw Custom Error
            throw StoreError.noPurchases
        //            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }
}
