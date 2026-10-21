import SwiftData
import SwiftUI

struct NarrowListItemStandardLayout: View {
    private enum Constants {
        static let balanceColumnWidth: CGFloat = 80
        static let dateColumnWidth: CGFloat = 64
    }

    @Environment(\.ledgerBalances)
    private var ledgerBalances

    @Environment(Item.self)
    private var item

    var body: some View {
        HStack {
            Text(item.localDate, format: .dateTime.month().day())
                .font(.subheadline)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(minWidth: Constants.dateColumnWidth, alignment: .leading)
            Divider()
            Spacer()
            VStack(alignment: .trailing, spacing: .zero) {
                TitleListItem()
                Text(item.netIncome.asCurrency)
                    .font(.footnote)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text((ledgerBalances[item.persistentModelID]?.asCurrency ?? ItemSummaryOperations.unavailableAmountText))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .monospacedDigit()
                .frame(minWidth: Constants.balanceColumnWidth, alignment: .trailing)
                .foregroundStyle((ledgerBalances[item.persistentModelID] ?? .zero) < .zero ? Color.red : Color.primary)
        }
    }
}
