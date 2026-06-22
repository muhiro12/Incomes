import SwiftUI

struct YearlyDuplicationProposalActionLayout: View {
    let inlineSpacing: CGFloat
    let isActionDisabled: Bool
    let edit: () -> Void
    let create: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: inlineSpacing) {
                YearlyDuplicationProposalEditButton(
                    isActionDisabled: isActionDisabled,
                    edit: edit
                )
                YearlyDuplicationProposalCreateButton(
                    isActionDisabled: isActionDisabled,
                    create: create
                )
            }

            VStack(alignment: .leading, spacing: inlineSpacing) {
                YearlyDuplicationProposalEditButton(
                    isActionDisabled: isActionDisabled,
                    edit: edit
                )
                YearlyDuplicationProposalCreateButton(
                    isActionDisabled: isActionDisabled,
                    create: create
                )
            }
        }
    }
}
