import Foundation
@testable import IncomesLibrary
import Testing

struct ItemFormInputTests {
    @Test
    func isValid_requires_content_and_valid_numbers() {
        let invalidContent = ItemFormInput(
            date: .now,
            content: "",
            incomeText: "100",
            outgoText: "0",
            category: "Category",
            priorityText: "1"
        )
        #expect(invalidContent.isValid == false)

        let invalidNumbers = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: "abc",
            outgoText: "10",
            category: "Category",
            priorityText: "1"
        )
        #expect(invalidNumbers.isValid == false)

        let valid = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: "1,000",
            outgoText: "",
            category: "Category",
            priorityText: "0"
        )
        #expect(valid.isValid == true)

        let invalidPriority = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: "100",
            outgoText: "0",
            category: "Category",
            priorityText: "1.5"
        )
        #expect(invalidPriority.isValid == false)
    }

    @Test
    func income_and_outgo_parse_to_decimal() {
        let input = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: "1000",
            outgoText: "250",
            category: "Category",
            priorityText: "2"
        )
        #expect(input.income == 1_000)
        #expect(input.outgo == 250)
    }

    @Test
    func init_with_amounts_maps_values_to_text_fields() {
        let date = Date(timeIntervalSince1970: 1_000)

        let input = ItemFormInput(
            date: date,
            content: "Content",
            income: 1_000,
            outgo: Decimal(string: "2500.5") ?? .zero,
            category: "Category",
            priority: 2,
            locale: Locale(identifier: "en_US")
        )

        #expect(input.date == date)
        #expect(input.content == "Content")
        #expect(input.incomeText == "1,000")
        #expect(input.outgoText == "2,500.5")
        #expect(input.category == "Category")
        #expect(input.priorityText == "2")
    }

    @Test
    func validate_throws_specific_errors() {
        let invalidContent = ItemFormInput(
            date: .now,
            content: "",
            incomeText: "100",
            outgoText: "0",
            category: "Category",
            priorityText: "1"
        )
        #expect(throws: ItemFormInput.ValidationError.self) {
            try invalidContent.validate()
        }

        let invalidIncome = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: "abc",
            outgoText: "0",
            category: "Category",
            priorityText: "1"
        )
        #expect(throws: ItemFormInput.ValidationError.self) {
            try invalidIncome.validate()
        }
    }

    @Test
    func storedCategory_normalizes_legacy_others_literal() {
        let input = ItemFormInput(
            date: .now,
            content: "Content",
            incomeText: "100",
            outgoText: "0",
            category: "Others",
            priorityText: "1"
        )

        #expect(input.storedCategory.isEmpty)
    }

    @Test
    func init_with_draft_maps_values_and_resolves_empty_priority() {
        let date = Date(timeIntervalSince1970: 1_000)
        let draft = ItemFormDraft(
            groupID: UUID(),
            date: date,
            content: "Subscription",
            incomeText: "100",
            outgoText: "",
            category: "Service",
            repeatMonthSelections: [
                .init(year: 2_026, month: 1)
            ],
            priorityText: ""
        )

        let input = ItemFormInput(draft: draft)

        #expect(input.date == date)
        #expect(input.content == "Subscription")
        #expect(input.incomeText == "100")
        #expect(input.outgoText.isEmpty)
        #expect(input.category == "Service")
        #expect(input.priorityText == "0")
    }

    @Test
    func init_with_item_maps_values_and_hides_zero_amounts() throws {
        let context = testContext
        let item = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2026-01-10T12:00:00Z"),
                content: "Subscription",
                income: 0,
                outgo: 1_250,
                category: "Service",
                priority: 3
            )
        )

        let input = ItemFormInput(
            item: item,
            locale: Locale(identifier: "en_US")
        )

        #expect(input.date == item.localDate)
        #expect(input.content == "Subscription")
        #expect(input.incomeText.isEmpty)
        #expect(input.outgoText == "1,250")
        #expect(input.category == "Service")
        #expect(input.priorityText == "3")
    }

    @Test
    func applying_year_month_tag_updates_date_and_preserves_other_values() throws {
        let context = testContext
        let input = ItemFormInput(
            date: shiftedDate("2026-01-10T12:00:00Z"),
            content: "Subscription",
            incomeText: "100",
            outgoText: "",
            category: "Service",
            priorityText: "3"
        )
        let tag = try Tag.create(context: context, name: "202605", type: .yearMonth)

        let updatedInput = input.applying(
            tag: tag,
            currentDate: shiftedDate("2026-06-10T12:00:00Z")
        )
        let components = Calendar.current.dateComponents(
            [.year, .month],
            from: updatedInput.date
        )

        #expect(components.year == 2_026)
        #expect(components.month == 5)
        #expect(updatedInput.content == "Subscription")
        #expect(updatedInput.incomeText == "100")
        #expect(updatedInput.category == "Service")
        #expect(updatedInput.priorityText == "3")
    }

    @Test
    func applying_content_tag_updates_content_and_preserves_date() throws {
        let context = testContext
        let date = shiftedDate("2026-01-10T12:00:00Z")
        let input = ItemFormInput(
            date: date,
            content: "Old",
            incomeText: "",
            outgoText: "",
            category: "",
            priorityText: "0"
        )
        let tag = try Tag.create(context: context, name: "Coffee", type: .content)

        let updatedInput = input.applying(
            tag: tag,
            currentDate: shiftedDate("2026-06-10T12:00:00Z")
        )

        #expect(updatedInput.date == date)
        #expect(updatedInput.content == "Coffee")
    }
}
