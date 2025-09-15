//
//  SpacerToolbarItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/07.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct SpacerToolbarItem: ToolbarContent {
    private let placement: ToolbarItemPlacement

    init(placement: ToolbarItemPlacement = .automatic) {
        self.placement = placement
    }

    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarSpacer(placement: placement)
        } else {
            ToolbarItem(placement: placement) {
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
        SpacerToolbarItem(placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button(action: {
            }) {
                Label(.init("Action"), systemImage: "plus")
            }
        }
    }
}
