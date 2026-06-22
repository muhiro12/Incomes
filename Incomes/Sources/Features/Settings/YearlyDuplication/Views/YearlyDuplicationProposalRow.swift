import SwiftUI

struct YearlyDuplicationProposalRow: View {
    let group: YearlyItemDuplicationGroup
    let isCreated: Bool
    let isActionDisabled: Bool
    let inlineSpacing: CGFloat
    let verticalPadding: CGFloat
    let summaryText: String
    let edit: () -> Void
    let create: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: inlineSpacing) {
            YearlyDuplicationProposalDetails(
                group: group,
                isCreated: isCreated,
                inlineSpacing: inlineSpacing
            )
            YearlyDuplicationProposalActionRow(
                inlineSpacing: inlineSpacing,
                isActionDisabled: isActionDisabled,
                edit: edit,
                create: create
            )
        }
        .padding(.vertical, verticalPadding)
        .contentShape(Rectangle())
        .contextMenu {
            Button("Edit", systemImage: "pencil", action: edit)
                .disabled(isActionDisabled)
            Button("Create", systemImage: "plus.circle", action: create)
                .disabled(isActionDisabled)
            Divider()
            CopyTextContextMenuButton(
                "Copy Summary",
                text: summaryText
            )
        }
    }
}
