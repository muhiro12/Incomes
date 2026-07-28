//
//  PositiveNetIncomeIndicator.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2026/06/10.
//

import SwiftUI

struct PositiveNetIncomeIndicator: View {
    let presentation: ItemSummaryOperations.NetIncomePresentation

    var body: some View {
        Image(systemName: "chevron.up")
            .foregroundStyle(presentation == .positive ? .accent : .clear)
            .accessibilityLabel(accessibilityLabel)
    }
}

private extension PositiveNetIncomeIndicator {
    var accessibilityLabel: Text {
        switch presentation {
        case .positive:
            Text("Positive net income")
        case .neutral:
            Text("Zero net income")
        case .negative:
            Text("Negative net income")
        }
    }
}
