import SwiftUI

struct BalanceEntryView: View {
    var entry: BalanceEntry

    private var monthTitle: String {
        let formatter: DateFormatter = .init()
        formatter.locale = .current
        formatter.dateFormat = "yyyy MMM"
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monthTitle)
                .font(.headline)

            HStack(spacing: 8) {
                Text("Balance")
                Spacer(minLength: 0)
                Text(entry.balanceText)
                    .foregroundStyle(.secondary)
                Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                    .foregroundStyle(entry.isPositive ? Color.accentColor : Color.red)
            }
            .font(.footnote)
            .padding(.leading, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
    }
}
