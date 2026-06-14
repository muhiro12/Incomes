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
        let hasPositiveNetIncome = tag.netIncome > .zero

        TagSummaryRowContent(
            displayName: tag.displayName,
            itemCount: itemCount,
            incomeText: tag.income.asCurrency,
            outgoText: tag.outgo.asMinusCurrency,
            hasDeficit: tag.hasDeficit,
            hasPositiveNetIncome: hasPositiveNetIncome
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(tag.displayName))
        .accessibilityValue(accessibilityValue(itemCount: itemCount))
    }
}

private extension TagSummaryRow {
    func accessibilityValue(itemCount: Int) -> Text {
        Text(verbatim: accessibilityValueParts(itemCount: itemCount)
                .formatted(.list(type: .and).locale(locale)))
    }

    func accessibilityValueParts(itemCount: Int) -> [String] {
        var parts = [
            String(localized: "Items: \(itemCount)"),
            String(localized: "Income: \(tag.income.asCurrency)"),
            String(localized: "Outgo: \(tag.outgo.asMinusCurrency)")
        ]

        if tag.hasDeficit {
            parts.append(String(localized: "Contains deficit items"))
        }

        if tag.netIncome > .zero {
            parts.append(String(localized: "Positive net income"))
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
