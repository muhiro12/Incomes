import SwiftUI

struct YearlyDuplicationProposalActionRow: View {
    let inlineSpacing: CGFloat
    let isActionDisabled: Bool
    let edit: () -> Void
    let create: () -> Void

    var body: some View {
        IncomesLiquidGlassControlGroup(spacing: inlineSpacing) {
            YearlyDuplicationProposalActionLayout(
                inlineSpacing: inlineSpacing,
                isActionDisabled: isActionDisabled,
                edit: edit,
                create: create
            )
        }
    }
}
