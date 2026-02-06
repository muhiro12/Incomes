import Foundation
@testable import IncomesLibrary
import Testing

struct DateFormattingStabilityTests {
    @Test("stableFixed returns distinct formatter instances")
    func stableFixed_returns_distinct_formatter_instances() {
        let firstFormatter = DateFormatter.stableFixed(.yyyy)
        let secondFormatter = DateFormatter.stableFixed(.yyyy)

        #expect(firstFormatter !== secondFormatter)
        #expect(firstFormatter.dateFormat == "yyyy")
        #expect(secondFormatter.dateFormat == "yyyy")
    }

    @Test("stableDefault returns distinct formatter instances")
    func stableDefault_returns_distinct_formatter_instances() {
        let locale: Locale = .init(identifier: "en_US")
        let firstFormatter = DateFormatter.stableDefault(.yyyyMMM, locale: locale)
        let secondFormatter = DateFormatter.stableDefault(.yyyyMMM, locale: locale)

        #expect(firstFormatter !== secondFormatter)
        #expect(firstFormatter.locale == locale)
        #expect(secondFormatter.locale == locale)
    }

    @Test("stable date formatting does not mix templates in concurrent calls")
    func stable_date_formatting_does_not_mix_templates_in_concurrent_calls() async {
        let date = Date(timeIntervalSince1970: 1_718_855_096)
        let locale: Locale = .init(identifier: "en_US")
        let expectedYear = date.stableStringValueWithoutLocale(.yyyy)
        let expectedYearMonth = date.stableStringValueWithoutLocale(.yyyyMM)
        let expectedLocalizedMonth = date.stableStringValue(.yyyyMMM, locale: locale)
        let dateString = "20250102"
        let iterationCount = 400

        await withTaskGroup(of: (String, String, String, String?).self) { taskGroup in
            for _ in 0..<iterationCount {
                taskGroup.addTask {
                    let year = date.stableStringValueWithoutLocale(.yyyy)
                    let yearMonth = date.stableStringValueWithoutLocale(.yyyyMM)
                    let localizedMonth = date.stableStringValue(.yyyyMMM, locale: locale)
                    let parsedDate = dateString.stableDateValueWithoutLocale(.yyyyMMdd)
                    let parsedString = parsedDate?.stableStringValueWithoutLocale(.yyyyMMdd)

                    return (year, yearMonth, localizedMonth, parsedString)
                }
            }

            for await (year, yearMonth, localizedMonth, parsedString) in taskGroup {
                #expect(year == expectedYear)
                #expect(yearMonth == expectedYearMonth)
                #expect(localizedMonth == expectedLocalizedMonth)
                #expect(parsedString == dateString)
            }
        }
    }
}
