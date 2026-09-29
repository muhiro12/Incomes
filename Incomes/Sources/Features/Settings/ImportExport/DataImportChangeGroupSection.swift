import SwiftUI

struct DataImportChangeGroupSection: View {
    let group: ItemImportDifference.ChangeGroup
    @Binding var resolution: ItemImportMergeDecisions.Resolution

    var body: some View {
        Section {
            Picker("Resolution", selection: $resolution) {
                Text("Keep current")
                    .tag(ItemImportMergeDecisions.Resolution.keepCurrent)
                Text("Use file")
                    .tag(ItemImportMergeDecisions.Resolution.useFile)
                Text("Keep both")
                    .tag(ItemImportMergeDecisions.Resolution.keepBoth)
            }
            .pickerStyle(.segmented)
            ForEach(Array(group.storeItems.enumerated()), id: \.offset) { _, storeItem in
                DataImportItemRow(item: storeItem.item, source: "Current")
            }
            ForEach(Array(group.fileItems.enumerated()), id: \.offset) { _, item in
                DataImportItemRow(item: item, source: "In file")
            }
        } header: {
            Text(verbatim: headerText)
        }
    }
}

private extension DataImportChangeGroupSection {
    var headerText: String {
        let content = group.id.content.isEmpty ? String(localized: "No description") : group.id.content
        guard let localDate = group.fileItems.first?.localDate else {
            return content
        }
        return localDate.formatted(.dateTime.year().month().day()) + " " + content
    }
}
