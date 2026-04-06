import Foundation
@testable import IncomesLibrary
import Testing

struct CategoryNameSupportTests {
    @Test
    func isOthersLike_treats_nil_empty_and_others_as_uncategorized() {
        #expect(CategoryNameSupport.isOthersLike(nil))
        #expect(CategoryNameSupport.isOthersLike(.empty))
        #expect(CategoryNameSupport.isOthersLike("Others"))
        #expect(CategoryNameSupport.isOthersLike("Food") == false)
    }

    @Test
    func displayName_returns_others_for_uncategorized_values() {
        #expect(
            CategoryNameSupport.displayName(
                forStoredName: nil
            ) == "Others"
        )
        #expect(
            CategoryNameSupport.displayName(
                forStoredName: .empty
            ) == "Others"
        )
        #expect(
            CategoryNameSupport.displayName(
                forStoredName: "Others"
            ) == "Others"
        )
        #expect(
            CategoryNameSupport.displayName(
                forStoredName: "Food"
            ) == "Food"
        )
    }

    @Test
    func areEquivalent_treats_uncategorized_values_as_the_same_bucket() {
        #expect(CategoryNameSupport.areEquivalent(nil, .empty))
        #expect(CategoryNameSupport.areEquivalent(nil, "Others"))
        #expect(CategoryNameSupport.areEquivalent(.empty, "Others"))
        #expect(CategoryNameSupport.areEquivalent("Food", "Food"))
        #expect(CategoryNameSupport.areEquivalent("Food", "Others") == false)
    }
}
