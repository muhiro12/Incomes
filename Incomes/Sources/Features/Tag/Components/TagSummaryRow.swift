//
//  TagSummaryRow.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/09/17.
//

import SwiftData
import SwiftUI

struct TagSummaryRow: View {
    @Environment(Tag.self)
    private var tag
    @Environment(\.locale)
    private var locale

    var body: some View {
        let itemCount = (tag.items ?? []).count
        let netIncomePresentation = ItemSummaryOperations.netIncomePresentation(
            for: tag.netIncome
        )

        TagSummaryRowContent(
            displayName: tag.displayName,
            itemCount: itemCount,
            incomeText: tag.income.asCurrency,
            outgoText: tag.outgo.asMinusCurrency,
            hasDeficit: tag.hasDeficit,
            netIncomePresentation: netIncomePresentation
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(tag.displayName))
        .accessibilityValue(accessibilityValue(itemCount: itemCount))
    }
}

private extension TagSummaryRow {
    var netIncomeAccessibilityText: String {
        switch ItemSummaryOperations.netIncomePresentation(for: tag.netIncome) {
        case .positive:
            String(localized: "Positive net income", locale: locale)
        case .neutral:
            String(localized: "Zero net income", locale: locale)
        case .negative:
            String(localized: "Negative net income", locale: locale)
        }
    }

    func accessibilityValue(itemCount: Int) -> Text {
        Text(verbatim: accessibilityValueParts(itemCount: itemCount)
                .formatted(.list(type: .and).locale(locale)))
    }

    func accessibilityValueParts(itemCount: Int) -> [String] {
        var parts = [
            String(
                localized: "Items: \(itemCount)",
                locale: locale
            ),
            String(
                localized: "Income: \(tag.income.currencyText(locale: locale))",
                locale: locale
            ),
            String(
                localized: "Outgo: \(tag.outgo.minusCurrencyText(locale: locale))",
                locale: locale
            )
        ]

        if tag.hasDeficit {
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
