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
                Label("\(entry.itemCount) Items", systemImage: "list.bullet")
                Spacer(minLength: 0)
                Label(entry.monthBalance, systemImage: "sum")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
    }
}
