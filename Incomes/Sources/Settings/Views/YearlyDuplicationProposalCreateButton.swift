import SwiftUI

struct YearlyDuplicationProposalCreateButton: View {
    let isActionDisabled: Bool
    let create: () -> Void

    var body: some View {
        Button("Create", systemImage: "plus.circle", action: create)
            .incomesProminentControlStyle()
            .disabled(isActionDisabled)
    }
}
