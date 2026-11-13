import SwiftUI

struct DataImportReplaceSection: View {
    let difference: ItemImportDifference

    var body: some View {
        if difference.unmatchedStoreItemCount > .zero {
            Section {
                ForEach(Array(removedItems.enumerated()), id: \.offset) { _, item in
                    DataImportItemRow(item: item)
                }
            } header: {
                Text("Items to remove")
            }
        }
        if difference.unmatchedFileItemCount > .zero {
            Section {
                ForEach(Array(addedItems.enumerated()), id: \.offset) { _, item in
                    DataImportItemRow(item: item)
                }
            } header: {
                Text("Items to add")
            }
        }
    }
}

private extension DataImportReplaceSection {
    var removedItems: [IncomesFileItem] {
        ItemImportOperations.replacementItems(difference: difference).removed
    }

    var addedItems: [IncomesFileItem] {
        ItemImportOperations.replacementItems(difference: difference).added
    }
}
