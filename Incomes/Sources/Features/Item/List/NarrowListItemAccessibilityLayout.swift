import SwiftData
import SwiftUI

struct NarrowListItemAccessibilityLayout: View {
    private enum Constants {
        static let verticalSpacing: CGFloat = 6
        static let horizontalSpacing: CGFloat = 8
        static let titleLineLimit = 2
    }

    @Environment(Item.self)
    private var item

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            NarrowListItemAccessibilityHeader(
                date: item.localDate,
                balanceText: item.balance.asCurrency,
                isBalanceNegative: item.balance < .zero,
                horizontalSpacing: Constants.horizontalSpacing
            )
            HStack(alignment: .top, spacing: Constants.horizontalSpacing) {
                Text(item.content)
                    .font(.headline)
                    .lineLimit(Constants.titleLineLimit)
                    .layoutPriority(1)
                PositiveNetIncomeIndicator(isVisible: item.netIncome > .zero)
            }
            Text(item.netIncome.asCurrency)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, Constants.verticalSpacing)
    }
}

#Preview("Accessibility Size", traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var items: [Item]

    List {
        NarrowListItemAccessibilityLayout()
            .environment(items[0])
        NarrowListItemAccessibilityLayout()
            .environment(items[1])
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}
