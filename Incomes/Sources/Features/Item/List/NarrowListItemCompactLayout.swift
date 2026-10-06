import SwiftUI

struct NarrowListItemCompactLayout: View {
    private enum Constants {
        static let spacing: CGFloat = 6
        static let titleLineLimit = 2
    }

    @Environment(Item.self)
    private var item

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.spacing) {
            NarrowListItemAccessibilityHeader(
                date: item.localDate,
                balanceText: item.balance.asCurrency,
                isBalanceNegative: item.balance < .zero,
                horizontalSpacing: Constants.spacing
            )
            HStack(alignment: .firstTextBaseline, spacing: Constants.spacing) {
                Text(item.content)
                    .font(.headline)
                    .lineLimit(Constants.titleLineLimit)
                Spacer(minLength: Constants.spacing)
                Text(item.netIncome.asCurrency)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .fixedSize(horizontal: true, vertical: false)
                PositiveNetIncomeIndicator(
                    presentation: ItemSummaryOperations.netIncomePresentation(
                        for: item.netIncome
                    )
                )
            }
        }
    }
}
