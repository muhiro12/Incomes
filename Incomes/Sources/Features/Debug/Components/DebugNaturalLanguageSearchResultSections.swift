#if DEBUG
import SwiftData
import SwiftUI

struct DebugNaturalLanguageSearchResultSections: View {
    @LedgerItemQuery private var fetchedItems: [Item]

    var body: some View {
        let results = NaturalLanguageSearchOperations.results(from: fetchedItems)

        Section {
            if results.items.isEmpty {
                Text("No saved items match these conditions.")
            } else if results.hasMoreItems {
                Text("""
                Showing the first \(NaturalLanguageSearchOperations.resultLimit) matching items. \
                Narrow the request to see others.
                """)
            } else {
                ItemCountStatusToolbarItem.localizedText(count: results.items.count)
            }
        } header: {
            Text("Saved Items")
        }
        ForEach(
            SearchResultOperations.sections(for: results.items),
            id: \.month
        ) { section in
            SearchResultSection(
                section: section,
                firstItemID: nil
            )
        }
    }

    init(conditions: ItemSearchConditions, ledgerIdentifier: LedgerIdentifier) {
        _fetchedItems = LedgerItemQuery(
            NaturalLanguageSearchOperations.resultDescriptor(for: conditions, ledgerIdentifier: ledgerIdentifier)
        )
    }
}
#endif
