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
            titleRow
            if group.category.isNotEmpty {
                Text(group.category)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            metadataText(
                "Dates: \(YearlyDuplicationPresentationOperations.monthDayListText(for: group))"
            )
            metadataText("Items: \(group.entryCount)")
            metadataText(
                "Income: \(YearlyDuplicationPresentationOperations.decimalString(from: group.averageIncome))"
            )
            metadataText(
                "Outgo: \(YearlyDuplicationPresentationOperations.decimalString(from: group.averageOutgo))"
            )
            actionRow
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

private extension YearlyDuplicationProposalRow {
    var titleRow: some View {
        HStack {
            Text(group.content)
                .font(.headline)
            if isCreated {
                Text("Created")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var actionRow: some View {
        HStack {
            Button("Edit", action: edit)
                .buttonStyle(.bordered)
                .disabled(isActionDisabled)
            Button("Create", action: create)
                .buttonStyle(.borderedProminent)
                .disabled(isActionDisabled)
        }
    }

    func metadataText(
        _ value: LocalizedStringKey
    ) -> some View {
        Text(value)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
