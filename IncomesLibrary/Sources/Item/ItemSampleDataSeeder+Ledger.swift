import Foundation
import SwiftData

// The ledger templates intentionally encode representative day offsets and amounts.
// swiftlint:disable no_magic_numbers

extension ItemSampleDataSeeder {
    enum LedgerDay {
        case first
        case second
        case third
        case fourth
        case fifth
    }

    struct LedgerDaySet {
        let firstDay: Date
        let secondDay: Date
        let thirdDay: Date
        let fourthDay: Date
        let fifthDay: Date

        init?(baseDate: Date) {
            let startOfYear = Calendar.current.startOfYear(for: baseDate)
            guard
                let firstDay = Calendar.current.date(byAdding: .day, value: 0, to: startOfYear),
                let secondDay = Calendar.current.date(byAdding: .day, value: 6, to: startOfYear),
                let thirdDay = Calendar.current.date(byAdding: .day, value: 12, to: startOfYear),
                let fourthDay = Calendar.current.date(byAdding: .day, value: 18, to: startOfYear),
                let fifthDay = Calendar.current.date(byAdding: .day, value: 24, to: startOfYear)
            else {
                return nil
            }
            self.firstDay = firstDay
            self.secondDay = secondDay
            self.thirdDay = thirdDay
            self.fourthDay = fourthDay
            self.fifthDay = fifthDay
        }

        func date(for day: LedgerDay) -> Date {
            switch day {
            case .first:
                firstDay
            case .second:
                secondDay
            case .third:
                thirdDay
            case .fourth:
                fourthDay
            case .fifth:
                fifthDay
            }
        }
    }

    struct LedgerItemTemplate {
        let day: LedgerDay
        let content: String
        let incomeBaseUSD: Decimal
        let outgoBaseUSD: Decimal
        let category: String
    }

    static func paydayTemplate() -> LedgerItemTemplate {
        .init(
            day: .fourth,
            content: String(localized: "Payday", table: "SampleData", bundle: .module),
            incomeBaseUSD: 4_500,
            outgoBaseUSD: 0,
            category: String(localized: "Salary", table: "SampleData", bundle: .module)
        )
    }

    static func ledgerItemTemplates() -> [LedgerItemTemplate] {
        salaryTemplates()
            + creditTemplates()
            + loanTemplates()
            + taxTemplates()
    }

    static func salaryTemplates() -> [LedgerItemTemplate] {
        [
            paydayTemplate(),
            .init(
                day: .fourth,
                content: String(localized: "Advertising revenue", table: "SampleData", bundle: .module),
                incomeBaseUSD: 500,
                outgoBaseUSD: 0,
                category: String(localized: "Salary", table: "SampleData", bundle: .module)
            )
        ]
    }

    static func creditTemplates() -> [LedgerItemTemplate] {
        [
            .init(
                day: .second,
                content: String(localized: "Apple card", table: "SampleData", bundle: .module),
                incomeBaseUSD: 0,
                outgoBaseUSD: 900,
                category: String(localized: "Credit", table: "SampleData", bundle: .module)
            ),
            .init(
                day: .first,
                content: String(localized: "Orange card", table: "SampleData", bundle: .module),
                incomeBaseUSD: 0,
                outgoBaseUSD: 600,
                category: String(localized: "Credit", table: "SampleData", bundle: .module)
            ),
            .init(
                day: .fourth,
                content: String(localized: "Lemon card", table: "SampleData", bundle: .module),
                incomeBaseUSD: 0,
                outgoBaseUSD: 500,
                category: String(localized: "Credit", table: "SampleData", bundle: .module)
            )
        ]
    }

    static func loanTemplates() -> [LedgerItemTemplate] {
        [
            .init(
                day: .fifth,
                content: String(localized: "House", table: "SampleData", bundle: .module),
                incomeBaseUSD: 0,
                outgoBaseUSD: 1_800,
                category: String(localized: "Loan", table: "SampleData", bundle: .module)
            ),
            .init(
                day: .third,
                content: String(localized: "Car", table: "SampleData", bundle: .module),
                incomeBaseUSD: 0,
                outgoBaseUSD: 300,
                category: String(localized: "Loan", table: "SampleData", bundle: .module)
            )
        ]
    }

    static func taxTemplates() -> [LedgerItemTemplate] {
        [
            .init(
                day: .first,
                content: String(localized: "Insurance", table: "SampleData", bundle: .module),
                incomeBaseUSD: 0,
                outgoBaseUSD: 250,
                category: String(localized: "Tax", table: "SampleData", bundle: .module)
            ),
            .init(
                day: .fifth,
                content: String(localized: "Pension", table: "SampleData", bundle: .module),
                incomeBaseUSD: 0,
                outgoBaseUSD: 300,
                category: String(localized: "Tax", table: "SampleData", bundle: .module)
            )
        ]
    }

    /// Two years starting at the base year.
    static func standardMonthOffsets() -> Range<Int> {
        0..<24
    }

    /// Ten years that end with the standard ledger's two years.
    static func largeLedgerMonthOffsets() -> Range<Int> {
        -96..<24
    }

    static func ledgerItemValues(
        daySet: LedgerDaySet,
        monthOffset: Int,
        template: LedgerItemTemplate,
        locale: Locale
    ) -> ItemStoredValues {
        let date = Calendar.current.date(
            byAdding: .month,
            value: monthOffset,
            to: daySet.date(for: template.day)
        ) ?? daySet.date(for: template.day)
        return .init(
            date: date,
            content: template.content,
            income: LocaleAmountConverter.localizedAmount(baseUSD: template.incomeBaseUSD, locale: locale),
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: template.outgoBaseUSD, locale: locale),
            category: template.category,
            priority: 0
        )
    }

    static func createLedgerItem(
        context: ModelContext,
        daySet: LedgerDaySet,
        monthOffset: Int,
        template: LedgerItemTemplate,
        locale: Locale
    ) throws -> Item {
        try Item.create(
            context: context,
            values: ledgerItemValues(
                daySet: daySet,
                monthOffset: monthOffset,
                template: template,
                locale: locale
            ),
            repeatID: .init()
        )
    }
}

// swiftlint:enable no_magic_numbers
