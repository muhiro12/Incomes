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
        let summary = tag.summary
        let incomeText = summary.income.asCurrency
        let outgoText = summary.outgo.asMinusCurrency

        TagSummaryRowContent(
            displayName: tag.displayName,
            itemCount: summary.itemCount,
            incomeText: incomeText,
            outgoText: outgoText,
            hasDeficit: summary.hasDeficit,
            hasNonnegativeNetIncome: ItemSummaryOperations.isNonnegativeNetIncome(
                summary.netIncome
            )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(tag.displayName))
        .accessibilityValue(
            accessibilityValue(
                summary: summary,
                incomeText: incomeText,
                outgoText: outgoText
            )
        )
    }
}

private extension TagSummaryRow {
    func accessibilityValue(
        summary: TagSummary,
        incomeText: String,
        outgoText: String
    ) -> Text {
        Text(verbatim: accessibilityValueParts(
            summary: summary,
            incomeText: incomeText,
            outgoText: outgoText
        )
        .formatted(.list(type: .and).locale(locale)))
    }

    func accessibilityValueParts(
        summary: TagSummary,
        incomeText: String,
        outgoText: String
    ) -> [String] {
        var parts = [
            String(
                localized: "Items: \(summary.itemCount)",
                locale: locale
            ),
            String(
                localized: "Income: \(incomeText)",
                locale: locale
            ),
            String(
                localized: "Outgo: \(outgoText)",
                locale: locale
            )
        ]

        if summary.hasDeficit {
            parts.append(
                String(
                    localized: "Contains deficit items",
                    locale: locale
                )
            )
        }

        if ItemSummaryOperations.isNonnegativeNetIncome(summary.netIncome) {
            parts.append(
                String(
                    localized: "No net loss",
                    locale: locale
                )
            )
        }

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
