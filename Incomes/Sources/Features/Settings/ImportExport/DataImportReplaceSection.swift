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
        (difference.storeOnlyItems + difference.changeGroups.flatMap(\.storeItems))
            .map(\.item)
            .sorted { left, right in
                left.isOrderedByDateBefore(right)
            }
    }

    var addedItems: [IncomesFileItem] {
        (difference.additions + difference.changeGroups.flatMap(\.fileItems))
            .sorted { left, right in
                left.isOrderedByDateBefore(right)
            }
    }
}

private extension IncomesFileItem {
    func isOrderedByDateBefore(_ other: Self) -> Bool {
        if date != other.date {
            return date < other.date
        }
        return content < other.content
    }
}
