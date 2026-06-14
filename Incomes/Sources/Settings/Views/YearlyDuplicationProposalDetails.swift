import SwiftUI

struct YearlyDuplicationProposalDetails: View {
    let group: YearlyItemDuplicationGroup
    let isCreated: Bool
    let inlineSpacing: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: inlineSpacing) {
            YearlyDuplicationProposalHeader(
                content: group.content,
                isCreated: isCreated
            )
            if !group.category.isEmpty {
                Text(group.category)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            YearlyDuplicationMetadataRow("Dates") {
                Text(YearlyDuplicationPresentationOperations.monthDayListText(for: group))
            }
            YearlyDuplicationMetadataRow("Items") {
                Text(group.entryCount, format: .number)
            }
            YearlyDuplicationMetadataRow("Income") {
                Text(YearlyDuplicationPresentationOperations.decimalString(from: group.averageIncome))
            }
            YearlyDuplicationMetadataRow("Outgo") {
                Text(YearlyDuplicationPresentationOperations.decimalString(from: group.averageOutgo))
            }
        }
        .accessibilityElement(children: .combine)
    }
}
