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
        Image(systemName: ItemSummaryOperations.NetIncomePresentation.positive.symbolName)
            .foregroundStyle(presentation == .positive ? .accent : .clear)
            .accessibilityLabel(Text("Positive net income"))
            // Nothing is drawn for the other directions, so VoiceOver stays
            // silent there instead of describing an invisible state.
            .accessibilityHidden(presentation != .positive)
    }
}
