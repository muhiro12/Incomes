import SwiftUI

struct YearlyDuplicationPromoContent: View {
    let promo: YearlyDuplicationPromoSection.ResolvedPromo
    let inlineSpacing: CGFloat
    let reviewProposals: () -> Void

    var body: some View {
        IncomesLiquidGlassControlGroup(spacing: inlineSpacing) {
            VStack(alignment: .leading, spacing: inlineSpacing) {
                YearlyDuplicationPromoHeader(
                    sourceYear: promo.sourceYear,
                    targetYear: promo.targetYear,
                    spacing: inlineSpacing
                )
                YearlyDuplicationPromoProposalSummary(
                    content: promo.proposal.content,
                    category: promo.proposal.category,
                    datesText: proposalDatesText,
                    itemCount: promo.proposal.entryCount,
                    spacing: inlineSpacing
                )
                YearlyDuplicationPromoReviewButton(
                    reviewProposals: reviewProposals
                )
            }
        }
        .padding(.vertical, inlineSpacing)
    }
}

private extension YearlyDuplicationPromoContent {
    var proposalDatesText: LocalizedStringKey {
        "Dates: \(YearlyDuplicationPresentationOperations.monthDayListText(for: promo.proposal))"
    }
}
