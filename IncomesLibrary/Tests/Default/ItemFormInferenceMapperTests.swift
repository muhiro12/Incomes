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

        if update.date?.stableStringValueWithoutLocale(.yyyyMMdd) != "20250102" {
            print("ItemFormInferenceMapperTests diagnostics: rawDateString=20250102")
            print("  update.date=\(String(describing: update.date))")
            if let date = update.date {
                print("  formatted=\(date.stableStringValueWithoutLocale(.yyyyMMdd))")
            }
            print("  locale=\(Locale.current.identifier) timeZone=\(TimeZone.current.identifier)")
            print("  calendar=\(Calendar.current.identifier) calendarTimeZone=\(Calendar.current.timeZone.identifier)")
        }

        #expect(update.date?.stableStringValueWithoutLocale(.yyyyMMdd) == "20250102")
        #expect(update.content == "Content")
        #expect(update.incomeText == "100")
        #expect(update.outgoText == "50")
        #expect(update.category == "Category")
    }
}
