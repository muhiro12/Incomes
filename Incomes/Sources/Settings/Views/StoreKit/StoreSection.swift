import StoreKit
import SwiftUI

struct StoreSection: View {
    @State private var product: Product?
    @State private var isLoadingProduct = false
    @State private var isPurchasing = false
    @State private var message: StoreSubscriptionMessage?

    var body: some View {
        Group {
            StoreSubscriptionSection(
                product: product,
                isLoadingProduct: isLoadingProduct,
                isPurchasing: isPurchasing,
                message: message,
                purchase: startPurchase,
                restorePurchases: startRestorePurchases
            )
            StoreSubscriptionPolicySection()
        }
        .task {
            await loadProductIfNeeded()
        }
    }

    @MainActor
    private func loadProductIfNeeded() async {
        guard product == nil,
              !isLoadingProduct else {
            return
        }

        isLoadingProduct = true
        defer {
            isLoadingProduct = false
        }

        do {
            product = try await Product.products(
                for: [IncomesMonetizationConfiguration.subscriptionProductID]
            )
            .first
            if product == nil {
                message = .loadFailed
            }
        } catch {
            message = .loadFailed
        }
    }

    private func startPurchase() {
        guard let product,
              !isPurchasing else {
            return
        }

        Task {
            await purchase(product)
        }
    }

    @MainActor
    private func purchase(_ product: Product) async {
        isPurchasing = true
        defer {
            isPurchasing = false
        }

        do {
            switch try await product.purchase() {
            case .success(let result):
                let transaction = try verifiedTransaction(from: result)
                await transaction.finish()
                message = .purchaseCompleted
            case .pending:
                message = .purchasePending
            case .userCancelled:
                break
            @unknown default:
                message = .purchaseFailed
            }
        } catch {
            message = .purchaseFailed
        }
    }

    private func startRestorePurchases() {
        guard !isPurchasing else {
            return
        }

        Task {
            await restorePurchases()
        }
    }

    @MainActor
    private func restorePurchases() async {
        isPurchasing = true
        defer {
            isPurchasing = false
        }

        do {
            try await AppStore.sync()
            message = .restoreRequested
        } catch {
            message = .purchaseFailed
        }
    }

    private func verifiedTransaction(
        from result: VerificationResult<StoreKit.Transaction>
    ) throws -> StoreKit.Transaction {
        switch result {
        case .verified(let transaction):
            return transaction
        case .unverified(_, let error):
            throw error
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    NavigationStack {
        List {
            StoreSection()
        }
    }
}
