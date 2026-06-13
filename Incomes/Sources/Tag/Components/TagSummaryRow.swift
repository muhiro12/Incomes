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
        let summary = Text("Items: \(itemCount)") +
            Text(verbatim: ", ") +
            Text("Income: \(tag.income.asCurrency)") +
            Text(verbatim: ", ") +
            Text("Outgo: \(tag.outgo.asMinusCurrency)")

        var result = summary

        if tag.hasDeficit {
            result = result +
                Text(verbatim: ", ") +
                Text("Contains deficit items")
        }

        if tag.netIncome > .zero {
            result = result +
                Text(verbatim: ", ") +
                Text("Positive net income")
        }

        return result
    }
}

#Preview(traits: .modifier(IncomesSampleData())) {
    @Previewable @Query var tags: [Tag]

    List {
        TagSummaryRow()
            .environment(tags[0])
    }
}
