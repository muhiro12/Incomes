import Foundation
@testable import IncomesLibrary
import Testing

struct TagTextSupportTests {
    private let japaneseOthers = "その他"

    @Test
    func displayName_formats_empty_category_as_localized_others() {
        #expect(
            TagTextSupport.displayName(
                name: .empty,
                type: .category,
                categoryOthersDisplayName: japaneseOthers
            ) == japaneseOthers
        )
    }

    @Test
    func displayName_formats_year_month_tags() {
        let displayName = TagTextSupport.displayName(
            name: "202401",
            type: .yearMonth
        )

        #expect(displayName != "202401")
    }

    @Test
    func matchesStoredName_matches_hiragana_and_katakana_variants() {
        #expect(
            TagTextSupport.matchesStoredName(
                "カタカナ",
                query: "かたかな"
            )
        )
    }

    @Test
    func matchesStoredName_returns_false_for_unrelated_query() {
        #expect(
            TagTextSupport.matchesStoredName(
                "Utilities",
                query: "Salary"
            ) == false
        )
    }

    @Test
    func matchesDisplayName_uses_localized_category_name() {
        #expect(
            TagTextSupport.matchesDisplayName(
                name: .empty,
                type: .category,
                query: japaneseOthers,
                categoryOthersDisplayName: japaneseOthers
            )
        )
        #expect(
            TagTextSupport.matchesDisplayName(
                name: .empty,
                type: .category,
                query: "Others",
                categoryOthersDisplayName: japaneseOthers
            )
        )
    }

    @Test
    func matchesDisplayName_uses_rendered_year_month_text() {
        let displayName = TagTextSupport.displayName(
            name: "202401",
            type: .yearMonth
        )

        #expect(
            TagTextSupport.matchesDisplayName(
                name: "202401",
                type: .yearMonth,
                query: displayName
            )
        )
    }
}
