import Foundation

/// Formats one saved Item for human-readable copying and sharing, without an import contract.
public enum ItemContentOperations {
    /// Returns localized content without identity, ledger, balance, priority, or recurrence metadata.
    /// An empty currency code leaves the amounts unlabelled; no currency is inferred or converted.
    public static func text(
        for item: Item,
        currencyCode: String,
        locale: Locale = .current
    ) -> String {
        let formatter = DateFormatter.default(.yyyyMMMd, locale: locale)
        formatter.calendar = .init(identifier: .gregorian)
        formatter.timeZone = .gmt
        let date = formatter.string(from: item.utcDate)
        let income = item.income.groupedDecimalText(locale: locale)
        let outgo = item.outgo.groupedDecimalText(locale: locale)
        let bundle = LocalizedStringResource.BundleDescription.atURL(Bundle.module.bundleURL)
        var lines = [
            String(localized: .init("Date: \(date)", locale: locale, bundle: bundle)),
            item.content,
            String(localized: .init("Income: \(income)", locale: locale, bundle: bundle)),
            String(localized: .init("Outgo: \(outgo)", locale: locale, bundle: bundle))
        ]
        if let category = item.category?.name, !category.isEmpty {
            lines.append(String(localized: .init("Category: \(category)", locale: locale, bundle: bundle)))
        }
        if !currencyCode.isEmpty {
            lines.append(String(localized: .init("Currency: \(currencyCode)", locale: locale, bundle: bundle)))
        }
        return lines.joined(separator: "\n")
    }
}
