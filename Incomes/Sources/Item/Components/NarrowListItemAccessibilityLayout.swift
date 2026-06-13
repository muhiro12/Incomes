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
            HStack(alignment: .firstTextBaseline, spacing: Constants.horizontalSpacing) {
                Text(item.localDate, format: .dateTime.month().day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: Constants.horizontalSpacing)
                Text(item.balance.asCurrency)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(IncomesTextScaling.minimumScaleFactor)
                    .foregroundStyle(item.balance < .zero ? Color.red : Color.primary)
            }
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
