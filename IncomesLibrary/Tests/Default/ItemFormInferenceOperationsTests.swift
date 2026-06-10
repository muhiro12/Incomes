import Foundation
@testable import IncomesLibrary
import Testing

struct ItemFormInferenceOperationsTests {
    @Test
    func languageCode_returns_locale_language() {
        #expect(
            ItemFormInferenceOperations.languageCode(
                for: Locale(identifier: "ja_JP")
            ) == "ja"
        )
    }

    @Test
    func instructions_describe_inference_role() {
        let instructions = ItemFormInferenceOperations.instructions()

        #expect(instructions.contains("household accounting and budgeting app"))
        #expect(instructions.contains("expert accountant"))
    }

    @Test
    func prompt_includes_current_date_language_requirements_and_user_input() {
        let prompt = ItemFormInferenceOperations.prompt(
            text: "Lunch yesterday 1200 yen",
            currentDate: localDate(year: 2_026, month: 6, day: 10),
            locale: Locale(identifier: "en_US")
        )

        #expect(prompt.contains("Today's date is: 20260610"))
        #expect(prompt.contains("Respond ONLY with the values in the language: en"))
        #expect(prompt.contains("- date (yyyyMMdd)"))
        #expect(prompt.contains(#"User input JSON string: "Lunch yesterday 1200 yen""#))
    }

    @Test
    func prompt_escapes_user_input_as_json_string() {
        let prompt = ItemFormInferenceOperations.prompt(
            text: "Lunch \"yesterday\"\nBackslash \\",
            currentDate: localDate(year: 2_026, month: 6, day: 10),
            locale: Locale(identifier: "en_US")
        )

        #expect(prompt.contains(#"User input JSON string: "Lunch \"yesterday\"\nBackslash \\""#))
    }

    @Test
    func prompt_uses_japanese_language_code() {
        let prompt = ItemFormInferenceOperations.prompt(
            text: "昨日の昼食 1200円",
            currentDate: localDate(year: 2_026, month: 6, day: 10),
            locale: Locale(identifier: "ja_JP")
        )

        #expect(prompt.contains("Respond ONLY with the values in the language: ja"))
        #expect(prompt.contains("like '来月', '先月'"))
    }

    @Test
    func stableIdentifier_includes_all_generated_fields() {
        let firstIdentifier = ItemFormInferenceOperations.stableIdentifier(
            date: "20260610",
            content: "Salary",
            income: 100,
            outgo: 0,
            category: "Work"
        )
        let secondIdentifier = ItemFormInferenceOperations.stableIdentifier(
            date: "20260610",
            content: "Salary",
            income: 0,
            outgo: 100,
            category: "Work"
        )

        #expect(firstIdentifier != secondIdentifier)
    }

    @Test
    func stableIdentifier_keeps_components_unambiguous_when_values_include_separator_characters() {
        let firstIdentifier = ItemFormInferenceOperations.stableIdentifier(
            date: "20260610",
            content: "A|B",
            income: 1,
            outgo: 2,
            category: "C"
        )
        let secondIdentifier = ItemFormInferenceOperations.stableIdentifier(
            date: "20260610|A",
            content: "B",
            income: 1,
            outgo: 2,
            category: "C"
        )

        #expect(firstIdentifier != secondIdentifier)
    }
}

private func localDate(year: Int, month: Int, day: Int) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .current

    var components = DateComponents()
    components.calendar = calendar
    components.timeZone = .current
    components.year = year
    components.month = month
    components.day = day

    return calendar.date(from: components) ?? Date(timeIntervalSince1970: .zero)
}
