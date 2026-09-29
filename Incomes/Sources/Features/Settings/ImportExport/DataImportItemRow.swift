import SwiftUI

/// One file or store item shown for review.
struct DataImportItemRow: View {
    let item: IncomesFileItem
    var source: LocalizedStringKey?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            details
            Spacer()
            VStack(alignment: .trailing) {
                if item.income != .zero {
                    Text(item.income.asCurrency)
                }
                if item.outgo != .zero || item.income == .zero {
                    Text(item.outgo.asMinusCurrency)
                }
            }
            .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}

private extension DataImportItemRow {
    var details: some View {
        VStack(alignment: .leading) {
            if let source {
                Text(source)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            if item.content.isEmpty {
                Text("No description")
                    .foregroundStyle(.secondary)
            } else {
                Text(item.content)
            }
            Text(item.localDate, format: .dateTime.year().month().day())
                .font(.caption)
                .foregroundStyle(.secondary)
            if !item.category.isEmpty {
                Text(item.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
