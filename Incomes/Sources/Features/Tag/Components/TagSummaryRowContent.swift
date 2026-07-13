import SwiftUI

struct TagSummaryRowContent: View {
    let displayName: String
    let itemCount: Int
    let incomeText: String
    let outgoText: String
    let hasDeficit: Bool
    let hasNonnegativeNetIncome: Bool

    var body: some View {
        ViewThatFits(in: .horizontal) {
            TagSummaryRowHorizontalLayout(
                displayName: displayName,
                itemCount: itemCount,
                incomeText: incomeText,
                outgoText: outgoText,
                hasDeficit: hasDeficit,
                hasNonnegativeNetIncome: hasNonnegativeNetIncome
            )
            TagSummaryRowVerticalLayout(
                displayName: displayName,
                itemCount: itemCount,
                incomeText: incomeText,
                outgoText: outgoText,
                hasDeficit: hasDeficit,
                hasNonnegativeNetIncome: hasNonnegativeNetIncome
            )
        }
    }
}
