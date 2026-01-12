import Foundation
@testable import IncomesLibrary
import Testing

struct ItemFormInferenceMapperTests {
    @Test
    func map_converts_fields_into_update() {
        let update = ItemFormInferenceMapper.map(
            dateString: "20250102",
            content: "Content",
            income: 100,
            outgo: 50,
            category: "Category"
        )

        #expect(update.date?.stringValueWithoutLocale(.yyyyMMdd) == "20250102")
        #expect(update.content == "Content")
        #expect(update.incomeText == "100")
        #expect(update.outgoText == "50")
        #expect(update.category == "Category")
    }
}
