import Foundation
import SwiftData

// Sample fixtures intentionally encode representative day offsets and amounts.
// swiftlint:disable no_magic_numbers

extension ItemSampleDataSeeder {
    enum PreviewDay {
        case first
        case second
        case third
        case fourth
        case fifth
    }

    struct PreviewDaySet {
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

        func date(for day: PreviewDay) -> Date {
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

    struct PreviewItemTemplate {
        let day: PreviewDay
        let content: String
        let incomeBaseUSD: Decimal
        let outgoBaseUSD: Decimal
        let category: String
    }

    static func paydayTemplate() -> PreviewItemTemplate {
        .init(
            day: .fourth,
            content: String(localized: "Payday", table: "SampleData", bundle: .module),
            incomeBaseUSD: 4_500,
            outgoBaseUSD: 0,
            category: String(localized: "Salary", table: "SampleData", bundle: .module)
        )
    }

    static func previewItemTemplates() -> [PreviewItemTemplate] {
        salaryTemplates()
            + creditTemplates()
            + loanTemplates()
            + taxTemplates()
    }

    static func salaryTemplates() -> [PreviewItemTemplate] {
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

    static func creditTemplates() -> [PreviewItemTemplate] {
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

    static func loanTemplates() -> [PreviewItemTemplate] {
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

    static func taxTemplates() -> [PreviewItemTemplate] {
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

    static func previewMonthOffsets() -> Range<Int> {
        0..<24
    }

    static func previewItemValues(
        daySet: PreviewDaySet,
        monthOffset: Int,
        template: PreviewItemTemplate
    ) -> ItemStoredValues {
        let date = Calendar.current.date(
            byAdding: .month,
            value: monthOffset,
            to: daySet.date(for: template.day)
        ) ?? daySet.date(for: template.day)
        return .init(
            date: date,
            content: template.content,
            income: LocaleAmountConverter.localizedAmount(baseUSD: template.incomeBaseUSD),
            outgo: LocaleAmountConverter.localizedAmount(baseUSD: template.outgoBaseUSD),
            category: template.category,
            priority: 0
        )
    }

    static func createPreviewItem(
        context: ModelContext,
        daySet: PreviewDaySet,
        monthOffset: Int,
        template: PreviewItemTemplate
    ) throws -> Item {
        try Item.create(
            context: context,
            values: previewItemValues(
                daySet: daySet,
                monthOffset: monthOffset,
                template: template
            ),
            repeatID: .init()
        )
    }
}

// swiftlint:enable no_magic_numbers
