//
//  ToolbarAlignmentSpacer.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct ToolbarAlignmentSpacer: ToolbarContent {
    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarSpacer()
        } else {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {}) {
                    Label(String.empty, systemImage: .empty)
                }
                .accessibilityHidden(true)
                .disabled(true)
                .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text("Toolbar Spacer Preview")
    }
    .toolbar {
        ToolbarAlignmentSpacer()
        ToolbarItem(placement: .bottomBar) {
            Button(action: {
            }) {
                Label(.init("Action"), systemImage: "plus")
            }
        }
    }
}
