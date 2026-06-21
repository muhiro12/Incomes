import SwiftUI
import TipKit

struct YearlyDuplicationPromoReviewButton: View {
    let reviewProposals: () -> Void

    private let yearlyDuplicationTip = YearlyDuplicationTip()

    var body: some View {
        Button("Review proposals", action: reviewProposals)
            .incomesSecondaryControlStyle()
            .popoverTip(yearlyDuplicationTip, arrowEdge: .top)
    }
}
