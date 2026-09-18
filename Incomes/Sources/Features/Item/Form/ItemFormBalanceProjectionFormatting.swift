import SwiftUI

/// Shared value formatting for reviewed balance projections.
enum ItemFormBalanceProjectionFormatting {
    static func signedCurrencyText(
        _ value: Decimal,
        locale: Locale = .current
    ) -> String {
        guard value > .zero else {
            return value.currencyText(locale: locale)
        }
        return "+\(value.currencyText(locale: locale))"
    }

    static func dateText(
        _ date: Date,
        locale: Locale = .current
    ) -> String {
        date.formatted(.dateTime.year().month().day().locale(locale))
    }

    static func dateRangeText(
        _ dateRange: ClosedRange<Date>,
        locale: Locale = .current
    ) -> String {
        let lowerBound = dateText(
            dateRange.lowerBound,
            locale: locale
        )
        guard !Calendar.current.isDate(
            dateRange.lowerBound,
            inSameDayAs: dateRange.upperBound
        ) else {
            return lowerBound
        }
        let upperBound = dateText(
            dateRange.upperBound,
            locale: locale
        )
        return "\(lowerBound) – \(upperBound)"
    }

    static func balanceStyle(
        for balance: Decimal?
    ) -> Color {
        guard let balance,
              balance < .zero else {
            return .primary
        }
        return .red
    }

    static func changeStyle(
        for difference: Decimal
    ) -> Color {
        if difference < .zero {
            return .red
        }
        if difference > .zero {
            return .green
        }
        return .secondary
    }
}

extension ItemMutationScope {
    static let balanceProjectionScopes: [ItemMutationScope] = [
        .thisItem,
        .futureItems,
        .allItems
    ]

    /// Compact title used by the projection scope picker.
    var balanceProjectionTitle: LocalizedStringKey {
        switch self {
        case .thisItem:
            "This"
        case .futureItems:
            "Future"
        case .allItems:
            "All"
        }
    }

    /// Full title used where the reviewed scope is reported back to the user.
    var balanceProjectionScopeTitle: LocalizedStringKey {
        switch self {
        case .thisItem:
            "This Item"
        case .futureItems:
            "Future Items"
        case .allItems:
            "All Items"
        }
    }
}

extension Decimal {
    var asSignedCurrency: String {
        ItemFormBalanceProjectionFormatting.signedCurrencyText(self)
    }
}
