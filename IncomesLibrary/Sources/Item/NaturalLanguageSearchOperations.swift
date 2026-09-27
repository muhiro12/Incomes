import Foundation
import SwiftData

/// Read-only operations for the experimental natural-language item search.
///
/// A language model only proposes a `NaturalLanguageSearchExtraction`. These
/// operations validate it deterministically and query saved items without
/// changing the store.
public enum NaturalLanguageSearchOperations {
    /// Result set limited to `limit` items.
    public struct Results {
        /// Matching items, newest first, up to the limit.
        public let items: [Item]
        /// True when more saved items match than `items` contains.
        public let hasMoreItems: Bool
    }

    /// Maximum number of result items shown for one search.
    public static let resultLimit = 50

    /// Maximum number of characters accepted in a request.
    public static var maximumRequestLength: Int {
        NaturalLanguageSearchValidator.maximumRequestLength
    }

    /// Builds the system instructions for search condition extraction.
    public static func instructions() -> String {
        FoundationModelPromptTemplate(
            resourceName: "natural-language-search-instructions"
        )
        .render()
    }

    /// Builds the user prompt for one already validated request.
    ///
    /// The prompt carries only the request. Relative months are resolved
    /// against the captured date during validation, so the model never sees
    /// a current date it could copy into explicit month fields.
    public static func prompt(request: String) -> String {
        FoundationModelPromptTemplate(
            resourceName: "natural-language-search-user-prompt"
        )
        .render(
            replacements: [
                "requestJSONString": PromptLiteralSupport.jsonStringLiteral(request)
            ]
        )
    }

    /// Returns the trimmed request, or throws before any generation when it cannot run.
    public static func validatedRequest(_ request: String) throws -> String {
        try NaturalLanguageSearchValidator.validatedRequest(request)
    }

    /// Validates an extraction against the request and a captured current date.
    ///
    /// Relative months resolve in the Gregorian calendar using `calendar`'s time zone.
    public static func conditions(
        from extraction: NaturalLanguageSearchExtraction,
        request: String,
        currentDate: Date,
        calendar: Calendar
    ) throws -> ItemSearchConditions {
        try NaturalLanguageSearchValidator.conditions(
            from: extraction,
            request: request,
            currentDate: currentDate,
            calendar: calendar
        )
    }

    /// Fetch descriptor that reads one item beyond the limit to detect more matches.
    /// Requested limits are bounded to `1...resultLimit`.
    public static func resultDescriptor(
        for conditions: ItemSearchConditions,
        limit: Int = resultLimit
    ) -> FetchDescriptor<Item> {
        var descriptor = FetchDescriptor.items(
            .matchesSearchConditions(conditions)
        )
        descriptor.fetchLimit = boundedLimit(limit) + 1
        return descriptor
    }

    /// Splits items fetched with `resultDescriptor(for:limit:)` into shown items and overflow.
    public static func results(
        from fetchedItems: [Item],
        limit: Int = resultLimit
    ) -> Results {
        .init(
            items: Array(fetchedItems.prefix(boundedLimit(limit))),
            hasMoreItems: fetchedItems.count > boundedLimit(limit)
        )
    }

    /// Reads current saved items matching `conditions` without changing the store.
    public static func results(
        context: ModelContext,
        conditions: ItemSearchConditions,
        limit: Int = resultLimit
    ) throws -> Results {
        results(
            from: try context.fetch(
                resultDescriptor(
                    for: conditions,
                    limit: limit
                )
            ),
            limit: limit
        )
    }
}

private extension NaturalLanguageSearchOperations {
    static func boundedLimit(_ limit: Int) -> Int {
        max(1, min(limit, resultLimit))
    }
}
