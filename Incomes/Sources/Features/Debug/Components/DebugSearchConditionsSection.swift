import SwiftUI

struct DebugSearchConditionsSection: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.calendar)
    private var calendar

    let conditions: ItemSearchConditions

    var body: some View {
        Section {
            if let period = conditions.period {
                LabeledContent("Period") {
                    Text(verbatim: periodText(period))
                }
            }
            if let content = conditions.content {
                LabeledContent("Item Name Contains") {
                    Text(verbatim: content)
                }
            }
            if let income = conditions.income {
                LabeledContent("Income") {
                    rangeText(income)
                }
            }
            if let outgo = conditions.outgo {
                LabeledContent("Outgo") {
                    rangeText(outgo)
                }
            }
        } header: {
            Text("Interpreted Conditions")
        } footer: {
            Text("Generated on device and may be wrong. Items must match every condition.")
        }
    }
}

private extension DebugSearchConditionsSection {
    func periodText(_ period: ItemSearchPeriod) -> String {
        guard let days = period.displayDays(in: calendar) else {
            return "\(period.year)-\(period.month)"
        }
        let style = Date.FormatStyle(
            date: .long,
            time: .omitted,
            locale: locale,
            calendar: calendar,
            timeZone: calendar.timeZone
        )
        return "\(days.first.formatted(style)) – \(days.last.formatted(style))"
    }

    func rangeText(_ range: ItemSearchAmountRange) -> Text {
        switch (range.minimum, range.maximum) {
        case let (minimum?, maximum?):
            Text("\(amountText(minimum)) to \(amountText(maximum))")
        case let (minimum?, nil):
            Text("At least \(amountText(minimum))")
        case let (nil, maximum?):
            Text("At most \(amountText(maximum))")
        case (nil, nil):
            Text(verbatim: "")
        }
    }

    func amountText(_ amount: Decimal) -> String {
        amount.groupedDecimalText(locale: locale)
    }
}
