import SwiftUI
import TipKit

struct YearlyDuplicationPromoContent: View {
    let promo: YearlyDuplicationPromoSection.ResolvedPromo
    let inlineSpacing: CGFloat
    let reviewProposals: () -> Void

    private let yearlyDuplicationTip = YearlyDuplicationTip()

    var body: some View {
        VStack(alignment: .leading, spacing: inlineSpacing) {
            Text("Duplicate Year")
                .font(.headline)
            Text(String(localized: "Year: \(promo.sourceYear) -> \(promo.targetYear)"))
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(String(localized: "Sample proposal"))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(promo.proposal.content)
                .font(.subheadline.weight(.semibold))
            if promo.proposal.category.isNotEmpty {
                Text(promo.proposal.category)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Text(String(localized: proposalDatesText))
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(String(localized: "Items: \(promo.proposal.entryCount)"))
                .font(.footnote)
                .foregroundStyle(.secondary)
            reviewProposalsButton
        }
        .padding(.vertical, inlineSpacing)
    }
}

private extension YearlyDuplicationPromoContent {
    var proposalDatesText: String.LocalizationValue {
        "Dates: \(YearlyItemDuplicationPresentationBuilder.monthDayListText(for: promo.proposal))"
    }

    var reviewProposalsButton: some View {
        Button("Review proposals", action: reviewProposals)
            .buttonStyle(.bordered)
            .popoverTip(yearlyDuplicationTip, arrowEdge: .top)
    }
}
