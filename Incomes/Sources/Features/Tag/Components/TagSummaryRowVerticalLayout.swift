import SwiftUI

struct TagSummaryRowVerticalLayout: View {
    private enum Constants {
        static let verticalSpacing: CGFloat = 6
    }

    let displayName: String
    let itemCount: Int
    let incomeText: String
    let outgoText: String
    let hasDeficit: Bool
    let netIncomePresentation: ItemSummaryOperations.NetIncomePresentation

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            TagSummaryRowTitle(
                displayName: displayName,
                itemCount: itemCount,
                hasDeficit: hasDeficit
            )
            TagSummaryRowAmounts(
                incomeText: incomeText,
                outgoText: outgoText,
                alignment: .leading
            )
            if netIncomePresentation == .positive {
                PositiveNetIncomeIndicator(presentation: netIncomePresentation)
            }
        }
    }
}
