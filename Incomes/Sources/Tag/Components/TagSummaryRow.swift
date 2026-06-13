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
        if tag.netIncome > .zero {
            Text(
                """
                Items: \(itemCount, format: .number), \
                Income: \(tag.income.asCurrency), \
                Outgo: \(tag.outgo.asMinusCurrency), \
                Positive net income
                """
            )
        } else {
            Text(
                """
                Items: \(itemCount, format: .number), \
                Income: \(tag.income.asCurrency), \
                Outgo: \(tag.outgo.asMinusCurrency)
                """
            )
        }
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    List {
        TagSummaryRow()
            .environment(tags[0])
    }
}
