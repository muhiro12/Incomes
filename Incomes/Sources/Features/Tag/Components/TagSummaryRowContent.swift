import SwiftUI

struct TagSummaryRowContent: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    let displayName: String
    let itemCount: Int
    let incomeText: String
    let outgoText: String
    let hasDeficit: Bool
    let netIncomePresentation: ItemSummaryOperations.NetIncomePresentation

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            TagSummaryRowVerticalLayout(
                displayName: displayName,
                itemCount: itemCount,
                incomeText: incomeText,
                outgoText: outgoText,
                hasDeficit: hasDeficit,
                netIncomePresentation: netIncomePresentation
            )
        } else {
            ViewThatFits(in: .horizontal) {
                TagSummaryRowHorizontalLayout(
                    displayName: displayName,
                    itemCount: itemCount,
                    incomeText: incomeText,
                    outgoText: outgoText,
                    hasDeficit: hasDeficit,
                    netIncomePresentation: netIncomePresentation
                )
                TagSummaryRowCompactLayout(
                    displayName: displayName,
                    itemCount: itemCount,
                    incomeText: incomeText,
                    outgoText: outgoText,
                    hasDeficit: hasDeficit,
                    netIncomePresentation: netIncomePresentation
                )
                TagSummaryRowVerticalLayout(
                    displayName: displayName,
                    itemCount: itemCount,
                    incomeText: incomeText,
                    outgoText: outgoText,
                    hasDeficit: hasDeficit,
                    netIncomePresentation: netIncomePresentation
                )
            }
        }
    }
}
