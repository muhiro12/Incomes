import SwiftUI

struct TagSummaryRowVerticalLayout: View {
    private enum Constants {
        static let verticalSpacing: CGFloat = 6
        static let horizontalSpacing: CGFloat = 8
    }

    let displayName: String
    let itemCount: Int
    let incomeText: String
    let outgoText: String
    let hasDeficit: Bool
    let hasPositiveNetIncome: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            TagSummaryRowTitle(
                displayName: displayName,
                itemCount: itemCount,
                hasDeficit: hasDeficit
            )
            HStack(alignment: .center, spacing: Constants.horizontalSpacing) {
                TagSummaryRowAmounts(
                    incomeText: incomeText,
                    outgoText: outgoText,
                    alignment: .leading
                )
                PositiveNetIncomeIndicator(isVisible: hasPositiveNetIncome)
            }
        }
    }
}
