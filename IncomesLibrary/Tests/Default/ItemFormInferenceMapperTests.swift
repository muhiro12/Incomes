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

        if update.date?.stringValueWithoutLocale(.yyyyMMdd) != "20250102" {
            print("ItemFormInferenceMapperTests diagnostics: rawDateString=20250102")
            print("  update.date=\(String(describing: update.date))")
            if let date = update.date {
                print("  formatted=\(date.stringValueWithoutLocale(.yyyyMMdd))")
            }
            print("  locale=\(Locale.current.identifier) timeZone=\(TimeZone.current.identifier)")
            print("  calendar=\(Calendar.current.identifier) calendarTimeZone=\(Calendar.current.timeZone.identifier)")
        }

        #expect(update.date?.stringValueWithoutLocale(.yyyyMMdd) == "20250102")
        #expect(update.content == "Content")
        #expect(update.incomeText == "100")
        #expect(update.outgoText == "50")
        #expect(update.category == "Category")
    }

    @Test
    func update_applied_to_input_replaces_inferred_fields_and_preserves_priority() {
        let currentDate = Date(timeIntervalSince1970: 1_000)
        let inferredDate = Date(timeIntervalSince1970: 2_000)
        let currentInput = ItemFormInput(
            date: currentDate,
            content: "Old content",
            incomeText: "10",
            outgoText: "20",
            category: "Old",
            priorityText: "3"
        )
        let update = ItemFormInferenceUpdate(
            date: inferredDate,
            content: "New content",
            incomeText: "100",
            outgoText: "50",
            category: "New"
        )

        let result = update.applied(to: currentInput)

        #expect(result.date == inferredDate)
        #expect(result.content == "New content")
        #expect(result.incomeText == "100")
        #expect(result.outgoText == "50")
        #expect(result.category == "New")
        #expect(result.priorityText == "3")
    }

    @Test
    func update_applied_to_input_keeps_current_date_when_inference_has_no_date() {
        let currentDate = Date(timeIntervalSince1970: 1_000)
        let currentInput = ItemFormInput(
            date: currentDate,
            content: "Old content",
            incomeText: "10",
            outgoText: "20",
            category: "Old",
            priorityText: "3"
        )
        let update = ItemFormInferenceUpdate(
            date: nil,
            content: "New content",
            incomeText: "100",
            outgoText: "50",
            category: "New"
        )

        let result = update.applied(to: currentInput)

        #expect(result.date == currentDate)
        #expect(result.priorityText == "3")
    }
}
