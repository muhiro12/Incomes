//
//  PositiveNetIncomeIndicator.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2026/06/10.
//

import SwiftUI

struct PositiveNetIncomeIndicator: View {
    let isVisible: Bool

    var body: some View {
        Image(systemName: "chevron.up")
            .foregroundStyle(isVisible ? .accent : .clear)
            .accessibilityLabel(Text("Positive net income"))
            .accessibilityHidden(!isVisible)
    }
}
