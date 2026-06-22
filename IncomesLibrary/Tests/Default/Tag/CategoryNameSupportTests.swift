import Foundation
@testable import IncomesLibrary
import Testing

struct CategoryNameSupportTests {
    private let japaneseOthers = "その他"

    @Test
    func isOthersLike_treats_nil_empty_and_others_as_uncategorized() {
        #expect(CategoryNameSupport.isOthersLike(nil))
        #expect(CategoryNameSupport.isOthersLike(""))
        #expect(CategoryNameSupport.isOthersLike("Others"))
        #expect(CategoryNameSupport.isOthersLike("Food") == false)
    }

    @Test
    func displayName_returns_localized_others_for_uncategorized_values() {
        #expect(
            CategoryNameSupport.displayName(
                forStoredName: nil,
                othersDisplayName: japaneseOthers
            ) == japaneseOthers
        )
        #expect(
            CategoryNameSupport.displayName(
                forStoredName: "",
                othersDisplayName: japaneseOthers
            ) == japaneseOthers
        )
        #expect(
            CategoryNameSupport.displayName(
                forStoredName: "Others",
                othersDisplayName: japaneseOthers
            ) == japaneseOthers
        )
        #expect(
            CategoryNameSupport.displayName(
                forStoredName: "Food",
                othersDisplayName: japaneseOthers
            ) == "Food"
        )
    }

    @Test
    func areEquivalent_treats_uncategorized_values_as_the_same_bucket() {
        #expect(CategoryNameSupport.areEquivalent(nil, ""))
        #expect(CategoryNameSupport.areEquivalent(nil, "Others"))
        #expect(CategoryNameSupport.areEquivalent("", "Others"))
        #expect(CategoryNameSupport.areEquivalent("Food", "Food"))
        #expect(CategoryNameSupport.areEquivalent("Food", "Others") == false)
    }

    @Test
    func normalizedStoredName_maps_localized_others_aliases_to_empty() {
        #expect(
            CategoryNameSupport.normalizedStoredName(
                forUserInput: japaneseOthers,
                othersDisplayName: japaneseOthers
            ).isEmpty
        )
        #expect(
            CategoryNameSupport.normalizedStoredName(
                forUserInput: "Others",
                othersDisplayName: japaneseOthers
            ).isEmpty
        )
        #expect(
            CategoryNameSupport.normalizedStoredName(
                forUserInput: "Food",
                othersDisplayName: japaneseOthers
            ) == "Food"
        )
    }

    @Test
    func matchesOthersDisplayName_matches_legacy_and_localized_aliases() {
        #expect(
            CategoryNameSupport.matchesOthersDisplayName(
                query: "その",
                othersDisplayName: japaneseOthers
            )
        )
        #expect(
            CategoryNameSupport.matchesOthersDisplayName(
                query: "Oth",
                othersDisplayName: japaneseOthers
            )
        )
        #expect(
            CategoryNameSupport.matchesOthersDisplayName(
                query: "Food",
                othersDisplayName: japaneseOthers
            ) == false
        )
    }
}
