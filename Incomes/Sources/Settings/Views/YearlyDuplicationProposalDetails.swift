import SwiftUI

struct YearlyDuplicationProposalDetails: View {
    private enum Constants {
        static let titleSpacing: CGFloat = 6
    }

    let group: YearlyItemDuplicationGroup
    let isCreated: Bool
    let inlineSpacing: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: inlineSpacing) {
            titleRow
            if !group.category.isEmpty {
                Text(group.category)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            metadataText(
                "Dates: \(YearlyDuplicationPresentationOperations.monthDayListText(for: group))"
            )
            metadataText("Items: \(group.entryCount)")
            metadataText(
                "Income: \(YearlyDuplicationPresentationOperations.decimalString(from: group.averageIncome))"
            )
            metadataText(
                "Outgo: \(YearlyDuplicationPresentationOperations.decimalString(from: group.averageOutgo))"
            )
        }
        .accessibilityElement(children: .combine)
    }
}

private extension YearlyDuplicationProposalDetails {
    var titleRow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: Constants.titleSpacing) {
                titleText
                createdStatusText
            }
            VStack(alignment: .leading, spacing: Constants.titleSpacing) {
                titleText
                createdStatusText
            }
        }
    }

    var titleText: some View {
        Text(group.content)
            .font(.headline)
    }

    @ViewBuilder var createdStatusText: some View {
        if isCreated {
            Text("Created")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    func metadataText(
        _ value: LocalizedStringKey
    ) -> some View {
        Text(value)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
