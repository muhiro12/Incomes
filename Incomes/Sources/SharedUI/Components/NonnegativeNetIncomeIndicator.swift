//
//  NonnegativeNetIncomeIndicator.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2026/06/10.
//

import SwiftUI

struct NonnegativeNetIncomeIndicator: View {
    let isVisible: Bool

    var body: some View {
        Image(systemName: "chevron.up")
            .foregroundStyle(isVisible ? .accent : .clear)
            .accessibilityLabel(Text("No net loss"))
            .accessibilityHidden(!isVisible)
    }
}
