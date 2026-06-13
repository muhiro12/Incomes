import SwiftUI

struct YearlyDuplicationProposalActionRow: View {
    let inlineSpacing: CGFloat
    let isActionDisabled: Bool
    let edit: () -> Void
    let create: () -> Void

    var body: some View {
        IncomesLiquidGlassControlGroup(spacing: inlineSpacing) {
            ViewThatFits(in: .horizontal) {
                horizontalActions
                verticalActions
            }
        }
    }
}

private extension YearlyDuplicationProposalActionRow {
    var horizontalActions: some View {
        HStack(spacing: inlineSpacing) {
            editButton
            createButton
        }
    }

    var verticalActions: some View {
        VStack(alignment: .leading, spacing: inlineSpacing) {
            editButton
            createButton
        }
    }

    var editButton: some View {
        Button("Edit", action: edit)
            .incomesSecondaryControlStyle()
            .disabled(isActionDisabled)
    }

    var createButton: some View {
        Button("Create", action: create)
            .incomesProminentControlStyle()
            .disabled(isActionDisabled)
    }
}
