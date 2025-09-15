//
//  StatusToolbarItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/09/15.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import SwiftUI

struct StatusToolbarItem: ToolbarContent {
    private let content: LocalizedStringResource

    init(_ content: LocalizedStringResource) {
        self.content = content
    }

    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .largeSubtitle) {
                Text(content)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            ToolbarItem(placement: .status) {
                Text(content)
                    .font(.footnote)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text("Text")
            .navigationTitle("Title")
            .toolbar {
                StatusToolbarItem("Status")
            }
    }
}
