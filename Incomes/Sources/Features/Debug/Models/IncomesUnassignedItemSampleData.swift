import SwiftData
import SwiftUI

/// A few unassigned records in an isolated preview store; no production defaults change.
struct IncomesUnassignedItemSampleData: PreviewModifier {
    private static let unassignedItemCount = 3

    static func makeSharedContext() throws -> IncomesPlatformEnvironment {
        let environment = try IncomesSampleData.makePreviewContext(profile: .standard)
        let context = environment.modelContainer.mainContext
        for item in try ItemQueryOperations.items(context: context).prefix(unassignedItemCount) {
            item.modify(tags: (item.tags ?? []).filter { $0.type?.isLedgerOwnership != true })
        }
        try context.save()
        return environment
    }

    func body(content: Content, context: IncomesPlatformEnvironment) -> some View {
        content.incomesPreviewPlatformEnvironment(context)
    }
}
