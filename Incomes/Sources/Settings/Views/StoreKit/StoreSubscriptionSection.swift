import StoreKit
import SwiftUI

struct StoreSubscriptionSection: View {
    private static let contentSpacing: CGFloat = 16
    private static let sectionVerticalPadding: CGFloat = 4
    private static let titleSpacing: CGFloat = 6
    private static let planSpacing: CGFloat = 12
    private static let priceMinimumSpacing: CGFloat = 12
    private static let loadingSpacing: CGFloat = 10
    private static let actionSpacing: CGFloat = 10

    let product: Product?
    let isLoadingProduct: Bool
    let isPurchasing: Bool
    let message: StoreSubscriptionMessage?
    let purchase: () -> Void
    let restorePurchases: () -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: Self.contentSpacing) {
                titleContent
                planContent
                messageContent
                actionContent
            }
            .padding(.vertical, Self.sectionVerticalPadding)
        }
    }

    private var titleContent: some View {
        VStack(alignment: .leading, spacing: Self.titleSpacing) {
            Text("Incomes Premium")
                .font(.headline)
            Text("Sync items with iCloud and browse without ads.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var planContent: some View {
        if let product {
            HStack(alignment: .firstTextBaseline, spacing: Self.planSpacing) {
                Text("Monthly Plan")
                    .font(.body.weight(.semibold))
                Spacer(minLength: Self.priceMinimumSpacing)
                Text(verbatim: product.displayPrice)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .accessibilityElement(children: .combine)
        } else if isLoadingProduct {
            HStack(spacing: Self.loadingSpacing) {
                ProgressView()
                    .controlSize(.small)
                Text("Loading Plan")
                    .foregroundStyle(.secondary)
            }
        } else {
            Label("Unable to load subscription.", systemImage: "exclamationmark.triangle")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var messageContent: some View {
        if let message {
            if message.isFailure {
                Text(message.text)
                    .font(.footnote)
                    .foregroundStyle(.red)
            } else {
                Text(message.text)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var actionContent: some View {
        VStack(spacing: Self.actionSpacing) {
            Button(action: purchase) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text("Subscribe")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(product == nil || isLoadingProduct || isPurchasing)

            Button(action: restorePurchases) {
                Text("Restore Purchases")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            .disabled(isPurchasing)
        }
        .controlSize(.large)
    }
}
