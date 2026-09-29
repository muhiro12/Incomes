import Foundation
import SwiftData

public extension ItemImportOperations {
    /// Compares a file with the store items inside its selection, without changing the store.
    static func difference(
        contents: IncomesFileContents,
        context: ModelContext
    ) throws -> ItemImportDifference {
        let items = try context.fetch(.items(.all))
        return ItemImportComparer.difference(
            fileItems: contents.items,
            storeItems: items.map { item in
                .init(
                    id: item.persistentModelID,
                    item: .init(item: item)
                )
            }
        )
    }
}
