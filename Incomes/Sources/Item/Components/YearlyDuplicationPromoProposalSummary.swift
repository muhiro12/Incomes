import SwiftUI

struct YearlyDuplicationPromoProposalSummary: View {
    let content: String
    let category: String
    let datesText: LocalizedStringKey
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
            Text(datesText)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("Items: \(itemCount)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
