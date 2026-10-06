import SwiftUI

struct TagSummaryRowCompactLayout: View {
    private enum Constants {
        static let spacing: CGFloat = 6
    }

    let displayName: String
    let itemCount: Int
    let incomeText: String
    let outgoText: String
    let hasDeficit: Bool
    let netIncomePresentation: ItemSummaryOperations.NetIncomePresentation

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.spacing) {
            TagSummaryRowTitle(
                displayName: displayName,
                itemCount: itemCount,
                hasDeficit: hasDeficit
            )
            HStack(spacing: Constants.spacing) {
                Text(incomeText)
                    .fixedSize(horizontal: true, vertical: false)
                Spacer(minLength: Constants.spacing)
                Text(outgoText)
                    .fixedSize(horizontal: true, vertical: false)
                PositiveNetIncomeIndicator(presentation: netIncomePresentation)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
    }
}
