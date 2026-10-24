//
//  TagSummaryRow.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/09/17.
//

import SwiftData
import SwiftUI

struct TagSummaryRow: View {
    @Environment(\.ledgerIdentifier)
    private var ledgerIdentifier

    @Environment(\.ledgerBalances)
    private var ledgerBalances

    @Environment(Tag.self)
    private var tag
    @Environment(\.locale)
    private var locale

    private let title: String?

    private var summary: ItemSummaryOperations.MonthlyTotals {
        get throws {
            try ItemSummaryOperations.totals(
                for: TagQueryOperations.items(for: tag, ledgerIdentifier: ledgerIdentifier)
            )
        }
    }

    private var hasDeficit: Bool {
        TagQueryOperations.items(for: tag, ledgerIdentifier: ledgerIdentifier).contains { item in
            (ledgerBalances[item.persistentModelID] ?? .zero) < .zero
        }
    }

    var body: some View {
        let itemCount = TagQueryOperations.items(for: tag, ledgerIdentifier: ledgerIdentifier).count
        let netIncomePresentation = ItemSummaryOperations.netIncomePresentation(
            for: (try? summary.netIncome) ?? .zero
        )

        TagSummaryRowContent(
            displayName: title ?? tag.displayName,
            itemCount: itemCount,
            incomeText: (try? summary.totalIncome)?.asCurrency ?? ItemSummaryOperations.unavailableAmountText,
            outgoText: (try? summary.totalOutgo)?.asMinusCurrency
                ?? ItemSummaryOperations.unavailableAmountText,
            hasDeficit: hasDeficit,
            netIncomePresentation: netIncomePresentation
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: accessibilityTitle))
        .accessibilityValue(accessibilityValue(itemCount: itemCount))
    }

    init(title: String? = nil) {
        self.title = title
    }
}

private extension TagSummaryRow {
    var accessibilityTitle: String {
        let titles = [title, tag.displayName].compactMap(\.self)
        return titles.formatted(.list(type: .and).locale(locale))
    }

    var netIncomeAccessibilityText: String {
        let netIncome: Decimal
        do {
            netIncome = try summary.netIncome
        } catch {
            return ErrorMessageOperations.message(from: error)
        }
        return switch ItemSummaryOperations.netIncomePresentation(for: netIncome) {
        case .positive:
            String(localized: "Positive net income", locale: locale)
        case .neutral:
            String(localized: "Zero net income", locale: locale)
        case .negative:
            String(localized: "Negative net income", locale: locale)
        }
    }

    func accessibilityValue(itemCount: Int) -> Text {
        Text(
            verbatim: accessibilityValueParts(itemCount: itemCount)
                .formatted(.list(type: .and).locale(locale))
        )
    }

    func accessibilityValueParts(itemCount: Int) -> [String] {
        let itemCountText = String(
            localized: "Items: \(itemCount)",
            locale: locale
        )
        let income: Decimal
        let outgo: Decimal
        do {
            income = try summary.totalIncome
            outgo = try summary.totalOutgo
        } catch {
            return [itemCountText, ErrorMessageOperations.message(from: error)]
        }
        var parts = [
            itemCountText,
            String(
                localized: "Income: \(income.currencyText(locale: locale))",
                locale: locale
            ),
            String(
                localized: "Outgo: \(outgo.minusCurrencyText(locale: locale))",
                locale: locale
            )
        ]

        if hasDeficit {
            parts.append(
                String(
                    localized: "Contains deficit items",
                    locale: locale
                )
            )
        }

        parts.append(netIncomeAccessibilityText)

        return parts
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    List {
        TagSummaryRow()
            .environment(tags[0])
    }
}
