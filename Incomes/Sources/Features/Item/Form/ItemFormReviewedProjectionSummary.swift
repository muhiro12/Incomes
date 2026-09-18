import SwiftUI

/// Reports the balance projection the user reviewed for the current draft.
struct ItemFormReviewedProjectionSummary: View {
    @Environment(\.locale)
    private var locale

    let review: ItemBalanceProjectionReview

    var body: some View {
        Group {
            if let scope = review.scope {
                LabeledContent("Reviewed Scope") {
                    Text(scope.balanceProjectionScopeTitle)
                }
            }
            LabeledContent("Affected Items") {
                Text(review.changedItemCount, format: .number)
            }
            if let affectedDateRange = review.affectedDateRange {
                LabeledContent("Affected Dates") {
                    Text(
                        verbatim: ItemFormBalanceProjectionFormatting.dateRangeText(
                            affectedDateRange,
                            locale: locale
                        )
                    )
                }
            }
            if let difference = review.comparison.latestBalanceDifference {
                LabeledContent("Change") {
                    Text(verbatim: difference.asSignedCurrency)
                }
            }
            if review.comparison.projected.hasNegativeBalance {
                Label(
                    "Balance becomes negative",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .foregroundStyle(.red)
            }
        }
    }
}
