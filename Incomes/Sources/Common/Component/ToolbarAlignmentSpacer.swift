//
//  ToolbarAlignmentSpacer.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ToolbarAlignmentSpacer: View {
    var body: some View {
        Button(action: {}) {
            Label(String.empty, systemImage: .empty)
        }
        .accessibilityHidden(true)
        .disabled(true)
        .allowsHitTesting(false)
    }
}
