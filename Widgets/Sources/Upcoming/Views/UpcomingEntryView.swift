import SwiftUI

struct UpcomingEntryView: View {
    var entry: UpcomingEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.titleText)
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(entry.detailText)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text(entry.amountText)
                        .foregroundStyle(.secondary)
                    Image(systemName: entry.isPositive ? "chevron.up" : "chevron.down")
                        .foregroundStyle(entry.isPositive ? Color.accentColor : Color.red)
                }
                .font(.footnote)
                .padding(.leading, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
    }
}
