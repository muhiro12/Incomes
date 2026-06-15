import SwiftUI

struct TagSummaryRowHorizontalLayout: View {
    private enum Constants {
        static let spacing: CGFloat = 8
        static let minimumSpacerLength: CGFloat = 8
        static let titleLayoutPriority: Double = 1
    }

    let displayName: String
    let itemCount: Int
    let incomeText: String
    let outgoText: String
    let hasDeficit: Bool
    let hasPositiveNetIncome: Bool

    var body: some View {
        HStack(alignment: .center, spacing: Constants.spacing) {
            TagSummaryRowTitle(
                displayName: displayName,
                itemCount: itemCount,
                hasDeficit: hasDeficit
            )
            .layoutPriority(Constants.titleLayoutPriority)
            Spacer(minLength: Constants.minimumSpacerLength)
            TagSummaryRowAmounts(
                incomeText: incomeText,
                outgoText: outgoText,
                alignment: .trailing
            )
            PositiveNetIncomeIndicator(isVisible: hasPositiveNetIncome)
        }
    }
}
