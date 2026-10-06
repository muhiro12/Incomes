import SwiftUI

struct NarrowListItemStandardLayout: View {
    private enum Constants {
        static let balanceColumnWidth: CGFloat = 80
        static let dateColumnWidth: CGFloat = 64
    }

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
            Divider()
            Text(item.balance.asCurrency)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .monospacedDigit()
                .frame(minWidth: Constants.balanceColumnWidth, alignment: .trailing)
                .foregroundStyle(item.balance < .zero ? Color.red : Color.primary)
        }
    }
}
