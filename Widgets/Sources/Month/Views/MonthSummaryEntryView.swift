import SwiftUI

struct MonthSummaryEntryView: View {
    var entry: MonthSummaryEntry

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
                Text("Total Income")
                Spacer(minLength: 0)
                Text(entry.totalIncomeText)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.up")
                    .foregroundStyle(.tint)
            }
            .font(.footnote)
            .padding(.leading, 12)

            HStack(spacing: 8) {
                Text("Total Outgo")
                Spacer(minLength: 0)
                Text(entry.totalOutgoText)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.down")
                    .foregroundStyle(.red)
            }
            .font(.footnote)
            .padding(.leading, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
    }
}
