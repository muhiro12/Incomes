import SwiftUI

struct YearlyDuplicationProposalEditButton: View {
    let isActionDisabled: Bool
    let edit: () -> Void

    var body: some View {
        Button("Edit", action: edit)
            .incomesSecondaryControlStyle()
            .disabled(isActionDisabled)
    }
}
