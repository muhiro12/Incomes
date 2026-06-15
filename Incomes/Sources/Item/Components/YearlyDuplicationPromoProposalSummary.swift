import SwiftUI

struct YearlyDuplicationPromoProposalSummary: View {
    let content: String
    let category: String
    let datesText: String
    let itemCount: Int
    let spacing: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text("Sample proposal")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(content)
                .font(.subheadline.weight(.semibold))
            if !category.isEmpty {
                Text(category)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            YearlyDuplicationMetadataRow("Dates") {
                Text(datesText)
            }
            YearlyDuplicationMetadataRow("Items") {
                Text(itemCount, format: .number)
            }
        }
    }
}
