import SwiftUI
import TipKit

struct YearlyDuplicationPromoContent: View {
    let promo: YearlyDuplicationPromoSection.ResolvedPromo
    let inlineSpacing: CGFloat
    let reviewProposals: () -> Void

    private let yearlyDuplicationTip = YearlyDuplicationTip()

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
                reviewProposalsButton
            }
        }
        .padding(.vertical, inlineSpacing)
    }
}

private extension YearlyDuplicationPromoContent {
    var proposalDatesText: LocalizedStringKey {
        "Dates: \(YearlyDuplicationPresentationOperations.monthDayListText(for: promo.proposal))"
    }

    var reviewProposalsButton: some View {
        Button("Review proposals", action: reviewProposals)
            .incomesSecondaryControlStyle()
            .popoverTip(yearlyDuplicationTip, arrowEdge: .top)
    }
}
