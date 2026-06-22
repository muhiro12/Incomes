import SwiftUI

struct NarrowListItemAccessibilityHeader: View {
    let date: Date
    let balanceText: String
    let isBalanceNegative: Bool
    let horizontalSpacing: CGFloat

    var body: some View {
        ViewThatFits(in: .horizontal) {
            horizontalLayout
            verticalLayout
        }
    }
}

private extension NarrowListItemAccessibilityHeader {
    var horizontalLayout: some View {
        HStack(alignment: .firstTextBaseline, spacing: horizontalSpacing) {
            dateText
            Spacer(minLength: horizontalSpacing)
            balanceTextView
        }
    }

    var verticalLayout: some View {
        VStack(alignment: .leading, spacing: horizontalSpacing) {
            dateText
            balanceTextView
        }
    }

    var dateText: some View {
        Text(date, format: .dateTime.month().day())
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    var balanceTextView: some View {
        Text(balanceText)
            .font(.headline)
            .lineLimit(1)
            .foregroundStyle(isBalanceNegative ? Color.red : Color.primary)
    }
}
